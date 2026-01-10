// ==============================================================================================================================
// AER - Assault Electromagnetic Rifle, by Arleen Lasleur; orig. concept around Aug 2012, active dev since May 2023
   class aerwpn extends weapon config(aercfg);     // comments hist date format: YYYY-MM-DD
//todo:
//  trigger notify without dependency.
//  exploding corpses setup info object
//  trigger() func take action and destroy this object
// ------------------------------------------------------------------------------------------------------------------------------
// Weapon design points:              Ignored/not a goal:                  Integrated features:          Misc groups:
//   - Upak CAR replacement             - not a RL/GL or heavy weapon        - translator
//   - Light and 24/7/365 carriable     - not a PDW, designed for attack     - flashlight         AERBLOCK - proj blocker
//   - Max universal usage              - not antimaterial rifle             - area map           AERTBLOCK - pj terrain block
//                                                                           - impact hammer      AERTARG - radarable pawn
//   AERBLOCK display HDM status icon, AERTBLOCK does not                                         AERIGNORE - generic ignore
//   AERIGNORE may be used for process interruption                                               AERTAGZONE - radartag allow
// Controls: --------------------------------------------------------------------------------------------------------------------
//   Mwheel fwd/back:  toggle aux operation   TransEvents data format:              Translator controls:
//   Rightmouse:       shield/select aux        1. Hard line break, hyphenable        Rightmouse: select/scroll
//   Leftmouse:        always fire              2. All EOLs must be stripped          Mwheel: do selected
//   Midmouse:         always laser pointer     Sample: see aer_setup()
//   Alt (dodgekey):   dodge/light/swap FF      TE.Hint="AERLOCSIGN","AERNOSAVE","AERIDM"               Recomm. user.ini:
//   Alt, WASD:        aux_oper alias           for location sign, nosave msgs or download
// Aux operations:                              TE.Hint="AERIDM OVPS 5000" - override payload      [Engine.Input]
//   LP (unselectable):    ST:                F1 F2:            VI: impact hammer (rmouse)         F1=AERToggleScreen
//   laser pointer         stealth device     forcefields           sniper selector (mwheel)       F2=ActivateTranslator
// --------------------------------------------------------------------------------------------    F3=AERToggleAreaMap
// Dependency-free mylevelable triggers:                                                           F4=AERToggleLight
//   class AERFeatureManager extends Triggers;     // apply/enable module                          Alt=AERForceDodge
//     defprops:   CollisionRadius=128   CollisionHeight=128   Group='AERFM_Feature'               MiddleMouse=AERToggleLaser
//   class AERFieldAttractor extends Triggers;     // EMR friendly collision                       MouseWheelUp=AERScrollUp
//     defprops:   CollisionRadius=96    CollisionHeight=96    !bCollideActors   bDirectional      MouseWheelDown=AERScrollDown
//   class AERPowerAccelerator extends Triggers;   // power spots
//     defprops:   CollisionRadius=128   CollisionHeight=128                        TansEvents infopanels appnote: do NOT use
//   class AERLaserDistractor extends Triggers;    // override O.L. for laser       triggerable Message= content, move actual
//     defprops:   CollisionRadius=128   CollisionHeight=128                        !bStatic TransEvents by AttachMover instead.
// ------------------------------------------------------------------------------------------------------------------------------
// TransMsg pseudo-HTML image resources for translator. How to use:
//
// 1. Draw texture with illustrations you want, 252x247 max. Current version of rendertexture() sets white color for images
//    and amber yellow (246,218,109) for text. Images are rendered AFTER text, overriding it. Images are output as W x H
//    areas where H is always set to 13 (due to 'aerfontsmb' font height is 13). You can use full 256 colors of indexed PCX.
// 2. Define texture region and occupied text area. Place spaces in that area of text (for float left/right layout).
// 3. Texture is rendered from corresponding textline, further Y lines. Y is integer designating how many textrows image
//    occupies, thus, in pixels H = (Y * 13), W = (X * 7).
// 4. The syntax of image placeholder example is "[>x72k3;" without quotes, explained below. Each variable may be of 36
//    unique pseudobytes. Codepage is 0-9,a-z where a=10, b=11, ..., z=36. All measurements are multipliers of font size (7x13)
// 5. Texture names must be set in order 0-7 in array
// 6. Framerate is constant and immutable
//
//         +------------- trigger marker
//         |          +-- terminator marker
//         |          |
// Format: [>N,A,X,Y,L;  (without commas)
//           | | | | |
//           | | | | +--- runlength (how much texture to use)
//           | | | +----- y coord in texture
//           | | +------- x coord in texture
//           | +--------- anim textures total (use nextup multiskins[])
//           +----------- texture number (multiskins[] contents)
//
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
//
//         var texture imgsrc[8];   // todo replace to multiskins[]
//
// ------------------------------------------------------------------------------------------------------------------------------
// bugtraq:
// laser become uncontrollable and floating, restores by off/on. caused by zone.actorenter(). fixed by do_leash_laser()
// stops detecting tagged targets, caused by newfov zeroed. fixed in processtargets()
// playselect() cleared translator queue disp, caused by aer_setup() none unchecked. fixed by transmsg_receiver contents check
// ------------------------------------------------------------------------------------------------------------------------------
// class       Am - ammo (internal, conventional)
// name        Gr - graphics (effects etc)
// prefixes    Pj - projectile (deco, dmg)
//             SN - spawn notify
//             Wk - periodic worker
// ==============================================================================================================================

// todo non-AER: EMI gun taking down turrets permanently (damage only stationarypawns), 
// todo:         dmg on usual scriptedpawn very reduced. no severe fire restrictions. some plasma/energy anims.
// ------------------------------------------------------------------------------------------------------------------------------
// todo:
// smart snipe disable (if pawn dist < 20 m, if hold rmb?)
// IDM: auto
// transmsg SLF recv: full, cross-level, revealness auto increment depend on CPS
// transmsg inscription: do not manage hist (auto destroy?)
// RPM control: shit
// STN/LCD: imo shit
// synth: mbshit
// cloak: rethink. enforce no shooting (done), slow movement, short avail

// todo: rewrite timer code from absolute to relative, timer=secondsamount instead of level.timeseconds.
// todo: decrease them by float deltatime in tick()

// todo: EMI/shutdown, mb lowbatt single projs have 0 penetrability
// todo: shdn mode: disable repower, lcd, fullauto
// todo: STN allblack screen (alter polygon transp/masked, make fullblack fonts)

// todo: radio propagation, trace transmitters rssi from all pathnodes and then store in level (maybe in pathnodes group)
// todo: use it for radio degrade. normal CPS on SLF is ~2.5 bytes/sec, we need to transfer 0.35x...0.57x of normal message.

//todo invis:
// only go into invis while cloak crystal is cool. make realistic temerature (cool down more while moving, in water)
// once turned on, it's heating. execute pawns enemy reset only first time, then invis may be broken.
// maybe it uses shieldcap, not core batt

// todo: forcefields are mobile but eats ton of energy, making shield ultimately better. (upd. not ultimately)
//       forcefield power supply scheme:
//       within radius of ffieldsupply, icons become green and consumes small energy (make field sustainable 3-4 min)
//       outside radius - normal icons (activatable) but insane power consume
// todo 250410 fastshield:
//       calc two RadiusActor zones for incoming projectiles
//       1. disjointable are only projs inside radiusring (inside external but outside internal)
//       2. disjoint only deaim them, not block. mb some are blockable (needs testing) or stronger deaim
//       3. disable proj.timer() for anti-seeking rockets
//       4. insane consume of energy when projs are within internal radius
//       5. too much consume on 4x. reduce. do slower charge. (annoys when switching auxmode)
// todo 250422:
//       different RPM setting for level progression, as well as features during Dakota modernizing weapon
//       300-400 initial
//       520: regular

// TODO:
// rewrite repeating code and move it to AERDataProvider if used in cross-class.
// max reduce processing
// eliminate func parm passage, less stack usage
// refactor color functions

// todo fix boxes momentum (on Lines of comms, steelbox fly if fire to it, at fence left to skj forcefield)

// todo areamap render: toggle by F3
//
// 1. export T3D -> SVG. Process SVG -> PNG. 256, 1024 etc max. Scale should be selectable (8:1 level, 4:1 level, 2:1 level)
// 2. these textures are topviews. may be filtered by height (z coord of T3D). maybe filter filtered t3d's (twopass)
// 3. autoshow them on LCD (only thiswalking height is fullwhite. other faded out)
// 4. place markers, regions etc (regions may be pretextured)

// TODO: fix penetrability. must pass thin doors only. must pass only hollow objects. tractors bulldozers etc should have emptiness
// todo: AllowTagTarget Zone or something like this. affect tick().picktarget() call, making acquire targets thru thin walls impossible.
//       firing at these targets should raise alarm.
//       upd: introduce seetagtargdirection? seetargspot? some pbject which define targ is visually observable (for cross-zone
//       solid glass rooms like Revelations)

// maybe Alt press (failed performdodge) then various keys. Alt,A = f1, Alt,D = f2 etc. maybe support twice alt press.
// light: maybe move from F4 to twice Alt

// disable laser makenoise, shit

// todo
// 1. forcefield does not stop some projectiles, fastshield blocks all
//    upd. stops all porjs, but FF can temporary open for outgoung AER projectiles, rendering Dakota vulnerable.
//         only F2 have this feature
// 2. skaarjs combatstyle adjuster, return to default (disable prefersnipe) after some inbattle time
//    singleshot snipe restores skaarjs snipeprefer
//    more than 2 shots in 0.4 sec prohibits chance to restore snipeprefer
//    affect radius skaarjs only
// 3. holdzoom playerviewoffset on rightmouse while areamap/transmsg (shield doesnt consume in this case)

// todo
// affect targeting by mouselook, pawn.viewrot will be delayed. todo alter playercontroller
// add leg step to rotate big angle

// todo
// areamap ct scan tool - autospawn falling DPNs, restrict by max dpn/radius (cancel span if found)
// areamap - reduce inactive layers brightness
// crosshair - gray crosshair (coordlock) behavior strange.

// todo
// new desired key behavior
// alt only - toggle light, swap ffields if they active
// mweehlpress - laser (keep as is)
// alt, w/s - toggle half firerate
// alt, turn l/r - ena fastshield/zoom
// mwheel - keep as is
// ? - toggle ignoretargets (do not force battlemode)


#exec obj load file="..\System\UnrealShare.u" package="UnrealShare"

#exec texture import file="textures\mask\aerpixel.png"    name="aerpixel"    package="AER" group="Mask" mips=1 flags=0 btc=-2
#exec texture import file="textures\mask\aerbearing.png"  name="aerbearing"  package="AER" group="Mask" mips=1 flags=2 btc=-2
#exec texture import file="textures\disp\aershieldbg.png" name="aershieldbg" package="AER" group="Disp" mips=1 flags=0 btc=-2
#exec texture import file="textures\disp\aerwarnxray.png" name="aerwarnxray" package="AER" group="Disp" mips=1 flags=0 btc=-2
//#exec texture new name="aerscreen" class="Engine.ScriptedTexture" group="Disp" usize=256 vsize=256 package="AER" // shit, fails
#exec obj load file="textures\aertex.utx" package="AER"   // import utx files but override packagename, to embed them

#exec texture import file="textures\disp\aermsg.png"     name="aermsg"     package="AER" group="Disp" mips=1 flags=0 btc=-2
#exec texture import file="textures\disp\aermsgtest.png" name="aermsgtest" package="AER" group="Disp" mips=1 flags=0 btc=-2 //todo delete this

#exec texture import file="textures\skin\aercoat.bmp" name="aercoat" package="AER" group="Skin" mips=1 flags=0 btc=-2
#exec texture import file="textures\skin\aermtl.bmp"  name="aermtl"  package="AER" group="Skin" mips=1 flags=0 btc=-2
#exec texture import file="textures\skin\aermtlb.bmp" name="aermtlb" package="AER" group="Skin" mips=1 flags=0 btc=-2

#exec font import file="textures\disp\aerfontbig.pcx" name="aerfontbig"               // 16x29
#exec font import file="textures\disp\aerfontsma.pcx" name="aerfontsma"               // 7x13
#exec font import file="textures\disp\aerfontsmb.pcx" name="aerfontsmb"               // 7x13 no-aa

// firesounds
//#exec audio import file="sounds\aerfire_mtlkick.wav" name="aerfire" package="AER" group="Sound"  // #1, hard

//#exec audio import file="sounds\aerfire_legacyb.wav" name="aerfire_reload" package="AER" group="Sound"   // #3, slow rpm
#exec audio import file="sounds\aerfire_d49cockb.wav" name="aerfire_reload" package="AER" group="Sound"

//#exec audio import file="sounds\aerfire_impact2.wav" name="aerfire" package="AER" group="Sound"   // #3, slow rpm
//#exec audio import file="sounds\aerfire_zippo.wav" name="aerfire" package="AER" group="Sound"
//#exec audio import file="sounds\aerfire_impact.wav" name="aerfire" package="AER" group="Sound"   // #4, fast rpm, best
//#exec audio import file="sounds\aerfire_dart.wav" name="aerfire" package="AER" group="Sound"       // these two are RC for final prod

#exec audio import file="sounds\aerlaseron.wav"  name="aerlaseron"  package="AER" group="Sound"
#exec audio import file="sounds\aerlaseroff.wav" name="aerlaseroff" package="AER" group="Sound"
#exec audio import file="sounds\aerpush_HBT.wav"     name="aerpush"     package="AER" group="Sound"
#exec audio import file="sounds\aermshum.wav"    name="aermshum"    package="AER" group="Sound"
#exec audio import file="sounds\aerffloop.wav"   name="aerffloop"   package="AER" group="Sound"
#exec audio import file="sounds\aerffsta.wav"    name="aerffsta"    package="AER" group="Sound"
#exec audio import file="sounds\aerffend.wav"    name="aerffend"    package="AER" group="Sound"
#exec audio import file="sounds\aerinvsta.wav"   name="aerinvsta"   package="AER" group="Sound"
#exec audio import file="sounds\aerinvend.wav"   name="aerinvend"   package="AER" group="Sound"
#exec audio import file="sounds\aerpickup.wav"   name="aerpickup"   package="AER" group="Sound"

#exec mesh import mesh="aerpick" anivfile="Models\aerpick_a.3d" datafile="Models\aerpick_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerpick" x=0 y=0 z=0
#exec mesh sequence mesh="aerpick" seq=All startframe=0 numframes=1
#exec meshmap new meshmap="aerpick" mesh="aerpick"
#exec meshmap scale meshmap="aerpick" x=0.60997 y=0.60997 z=1.21994
#exec mesh import mesh="aerview" anivfile="Models\aerview_a.3d" datafile="Models\aerview_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerview" x=0 y=0 z=0
#exec mesh sequence mesh="aerview" seq=All startframe=0 numframes=1
#exec meshmap new meshmap="aerview" mesh="aerview"
#exec meshmap scale meshmap="aerview" x=0.60997 y=0.60997 z=1.21994

var string debugstr;
// --- canvas related ------------------------------------------------------------------------------------------------------
var float    scale1,       // how wider is screen to 640px, needed for correct radardot coords, a.w.a matched FOV
             scale128, scale256, clipxdiv2, clipydiv2;  // for faster calc
var bool     canvas_set,ena_render_scope;
var AerGr_FI canvas_finfo; // just more readable font for debug vars
// --- apscan related ------------------------------------------------------------------------------------------------------
const                   apscan_horzres = 16;
const                   apscan_vertres = 12;
struct scanbar        { var byte data[apscan_vertres]; };
var scanbar             screenbuffer[apscan_horzres],screendata;
var byte scanline;
var float               maxdist,savedist;
var bool                ena_apscan;                     // for init delay
// --- zoom, FOV, mouse, timers --------------------------------------------------------------------------------------------
var globalconfig int    UserSetFOV;
struct aertimers      {
    var float    _refire,     _reaim,      _unsnipe,    _unfeel,     _redodge,    _reammo,     _repower,  _hitsens,
                 _showmsg,    _hidemsg,    _dlmsg,      _reclick,    _unwarnom,   _unwarnaux,  _repush,   _readvhello,
                 _rescan,     _releash,    _refeature,  _clrpenmon,  _unspanff,   _reffsta[2], _sh_cap,   _sh_dmgdec,
                 _redisch,    _rechrg,     _unobj,      _untrig,     _rerssi,     _initscan; };
var bool                ava_synth, boost_power;     // faster flags todo replace 'boost_power' with int powersrc_level
var bool                bZoomScreen;
var aertimers           decline_timer;
var float               last_firetime;
var float               initial_mousesens;
var int                 range,    range_targ,    initial_fov,    zoomfactor,    newfov;
// --- onetap dodge --------------------------------------------------------------------------------------------------------
var globalconfig bool   InfiniteDodge;
var globalconfig string MapForceDodgeKeyName;
var bool                forced;      // true if dodge executed
var int                 xdir, ydir;
// --- primary fire related ------------------------------------------------------------------------------------------------
var globalconfig bool   InfiniteAmmo;

//const                   BaseFireInterval       = 0.240; // 250 RPM     2025-05-20    very beginning AER fire rate
//const                   BaseScrollInterval     = 0.120; // BSI = BFI/2
//const                   BaseFireInterval       = 0.186; // 322 RPM     2025-07-27
//const                   BaseScrollInterval     = 0.093;
//const                   BaseFireInterval       = 0.170; // 352 RPM     2025-09-23
//const                   BaseScrollInterval     = 0.085;
//const                   BaseFireInterval       = 0.158; // 380 RPM     2025-07-27
//const                   BaseScrollInterval     = 0.079;
//const /* lowest */      BaseFireInterval       = 0.142; // 420 RPM     2025-07-20
//const                   BaseScrollInterval     = 0.071;
// //  const                   BaseFireInterval       = 0.132; // 450 RPM     2025-06-22
// //  const                   BaseScrollInterval     = 0.066;
  /* =============================================================================
   todo NEW SPEED DATA:
   ALL firespeeds below are conflicting btw goofing reload sound, prefer to use upper.
   ============================================================================= */
const                   BaseFireInterval       = 0.124; // 483 RPM     2025-07-07
const                   BaseScrollInterval     = 0.062;
//const /* highest */     BaseFireInterval       = 0.114; // 526 RPM     unkn         THESE VARS ARE IDEAL
//const                   BaseScrollInterval     = 0.057; //                             DO NOT TOUCH.
//const                   BaseFireInterval       = 0.110; // 545 RPM     2025-08-03
//const                   BaseScrollInterval     = 0.055;
//const /**/              BaseFireInterval       = 0.094; // 640 RPM     2025-02-01
//const                   BaseScrollInterval     = 0.047;
//const                   BaseFireInterval       = 0.090; // 666 RPM     2025-07-27
///const                   BaseScrollInterval     = 0.045;
//const                   BaseFireInterval       = 0.074; // 810 RPM     2025-04-22  shit
//const                   BaseScrollInterval     = 0.037;

const                   BIOSFireInterval       = 0.180;  // mbshit
const                   BaseRepowerInterval    = 0.050;  // was .095
const                   power_max_bot = 22;  // power_max worst/best bounds
const                   power_max_top = 63;
var travel byte         power_max;   // was 54 // todo change synth stuff // consume 3x power. deal with blue disp marks
var byte                deaim_rate,fire_idle_chg;
const                   deaim_max = 18;
var travel int          ammo_max;
const                   ammo_clip = 120;
const                   synth_max = 5;
var travel int          power_chg, ammo_chg, batt_chg, synth_chg;  // override std unreal ammo due to shitty WeaponChange() behavior
struct penmon_entry   { var byte    _rem,  _full,  _admg; };
const                   penmon_capacity = 140;
var penmon_entry        penetrability_monitor[penmon_capacity];
var AerGr_FP            FirePlayers[3];
// --- battery related -----------------------------------------------------------------------------------------------------
const                   batt_full              = 140000;
const                   batt_clip              = 14000;
const                   batt_min_one           = 1400;  // 1%
const                   batt_min_two           = 2800;  // 2%, unused
const                   batt_min_four          = 5600;  // 4%
const                   batt_min_five          = 7000;  // 5%
const                   batt_per_powercap      = 130;
const                   batt_per_powercap_fast = 30;
const                   batt_per_shield        = 11;
const                   shield_per_dodge       = 130;
// --- forcefield/shield related -------------------------------------------------------------------------------------------
var AerGr_ffield        forcefield[2];
var AerWk_FSS           shield_blk;
var byte                state_forcefield[2];
var byte                dist_field[2];
var triggers            sensed_forcefield_attractor;
var travel bool         ena_fast_shield;
var travel int          fast_shield_chg;
var byte                populated_shield_dmg;
var byte                incoming_danger;
// --- EMI shock related----------------------------------------------------------------------------------------------------
var travel float        decline_timer_unshock;
var travel bool         ena_emi;
// --- other operations ----------------------------------------------------------------------------------------------------
var globalconfig float  RClickExecCmdMax,                                   // fast rclick speed
                        RClickChgModeMin, RClickChgModeMax,                 // short holdclick speed
                        RClickExecAltCmdMin, RClickExecAltCmdMax,           // long holdclick speed
                        PushInterval;                                       // airvortex
var globalconfig bool   DisablePushCorridorBalance, bAutoMapKeys,
                        DisableReader, DisableHitsens;
var byte                mwheel_trig,                                        // exec modechange threshold
                        cursor_blink_pos;
var bool                last_scrollproc_updir;                              // mwheel aux_oper engage debounce threshold
var bool                ena_translator, ena_invis, ena_fullauto, ena_areamap;
var travel byte         aux_oper;         // 0=laser (unused); 1,2=forcefields; 3=invis; 4=vortex impact push/fastshield
var byte                tds_oper;         // 0=select; 1=scroll
var float               aux_old_yaw, cap_process_slowdown;
var bool                low_batt,low_repower,
                        fired,                                              // semiautofire flag
                        bMyOwnsCrosshair,                                   // altfire_set/clr eligibility flag
                        snipe,                                              // crosshair flag in battle mode
                        warn_aux,                                           // aux_oper change error flag
                        warn_opermsg,                                       // aux_oper text messages visible
                        pw_sens_fire, pw_sens_altfire, pw_sens_crouch;      // pawn control sensors
var string              aux_oper_msg[2];
var travel bool         ava_invis, ava_ffield, ava_fullscan;
var byte                modem_rssi;
// --- laser ---------------------------------------------------------------------------------------------------------------
var AerGr_laser         laserdot,laserdotsec;                               // primary, secondary laser
var AerGr_light         lightbeam;                                          // underbarrel flashlight
var travel bool         ava_laser, ena_laser;
var bool                inhibit_laser, laser_upon_invis, anylock, surelock, hdmlock;
var int                 LaserFlags;                                         // texture flags for laser blast
var vector              owner_location;
var rotator             owner_viewrotation;
// --- message reader ------------------------------------------------------------------------------------------------------
var globalconfig float  HideMsgInterval;
var bool                transmsg_proximity;   // shadowcopy stored in local vars. does not check altmessage
                                              // upd: according to TranslatorEvent code, no altmessage checks is necess
                                              // NFI why won't show alt messages (check behavior on Dig, Foundry levels)
var bool                trans_msg_areasign;            
const                   translator_max_cols  = 34;                    // design customization
const                   translator_max_rows  = 13;
const                   areasign_max_cols    = 14;
const                   areasign_max_rows    = 4;
var string              transmsg_screendata[translator_max_rows];     // video mem
var string              areasign_screendata[areasign_max_rows];
const                   transmsg_coordbar = "0123456789abcdefghijklmnopqrstuvwxyz";
var byte                anim_dl;
var texture             transmsg_img_data;
var int                 transmsg_applied_scroll, transmsg_remain_scroll;
var AerWk_TDS           transmsg_receiver;
var translatorevent     transmsg_last_known;          // used by forget process
// --- radar ---------------------------------------------------------------------------------------------------------------
const                   radar_max = 8;         // exceeds 255 bytes max static if more // todo mb delete color, save 16 more bytes
var globalconfig byte   RadarScanInterval;
var globalconfig float  RadarScanRadius;
var byte                radar_qty, radar_vqty;        // total/visible qty
struct radar_data     { var int   x, y, r, g, b;      // todo can be shrunken more down to byte. now need int because of -1 stuff.
                        var bool  ena, hit;           // todo mb use colors 250-255 as bitfield instead of flags, for less mem usage
                        var name  t; };               // targ link
var radar_data          radar[radar_max];             // pivot aiming
struct radarlock_data { var int   x[8], y[8]; };      // these 8 are for t1t2t3t4 b1b2b3b4 dots of collisionbox, not eight targs!
var radarlock_data      radarlock[radar_max];         // collision box aiming
var bool                ignore_hitsens_trig, ignore_hitsens_rst;
// ---  compass mark related -----------------------------------------------------------------------------------------------
var vector              pos_objective;
var bool                ava_objective,
                        ena_objective;
// --- cmos setup ----------------------------------------------------------------------------------------------------------
var globalconfig bool   DisableMenuSound;
var bool                ena_setup, entering_setup;    // setup start done/processing
var byte                setup_room_qc,                // room quality counter, would be less than 6 if unhappy spawn
                        seq_hello,                    // anim frame number
                        cmos_mode, cmos_sel, cmos_sel_max;           // menu nav
var string              setup_menu_hdr, setup_menu_line[7];          // screen contents
var vector              btn_origin;                                  // used by maxdist setup shdn
// --- progression ---------------------------------------------------------------------------------------------------------
var travel bool         ena_synth,                    // 16 Hz + taryd rod synth camera
                        ena_cloak,                    // cloak crystal
                        ena_powercell,                // morepower, negate FF batt consume
                                                      // todo mb FField use separate tarydbio ammo
                        ena_moreammo_2x,              // up to 480 ammo clip
                        ena_moreammo_3x;              // up to 720
// todo pack this into bitfield byte, also check other travel vars incl their names. keep going on low browsestring length profile
// -------------------------------------------------------------------------------------------------------------------------

function calccoords(canvas c){
   scale1 = c.clipx / 640;   // maybe *0.0015625
   scale128 = scale1 * 128;
   scale256 = scale1 * 256;
   clipxdiv2 = c.clipx >> 1;  // was /2
   clipydiv2 = c.clipy >> 1;  // was /2
   canvas_set = true;
}

function processprojectiles(playerpawn p){
   local projectile t;
   local int xp, yp;
   local int dmg;
   local vector dir;
   local float dist;
   local vector x, y, z;
   local bool prj_lock;
   incoming_danger = 0;
   if(low_batt) return;
   foreach VisibleCollidingActors(class'projectile', T, 12800){
      if(bool(aerprjhurtdmg(t)) || bool(aerprjbloodspurt(t))) continue;
      if(bool(aerprjpushdeco(t)) || bool(aerprjpushmove(t))) continue;
      if(vsizesq(t.velocity) < 100) continue;
      getaxes(t.rotation, x, y, z);
      dir = p.location - t.location;
      dist = vsize(dir);
      dmg = clamp(dist,0,2560);
      dmg = (2560-dmg) >> 11;
      dmg = clamp(dmg,1,16);
      if(dist<768) dmg += 4;
      if(dist<512) dmg += 8;
      if(dist<384) dmg += 12;
      if(dist>1280) dmg *= 2;   // more sensitivity to far projs
      if(t.damage>50) dmg *= 2;
      dir /= dist;
      prj_lock = false;
      if((dir dot x) < 0.7) continue;
      xp = ( (dir dot y)) * 320 / (dir dot x);
      yp = (-(dir dot z)) * 320 / (dir dot x);
      prj_lock = (abs(xp)<=32 && abs(yp)<=32);   // was <=24/24
      if(!prj_lock) continue;
      if(incoming_danger < (64-dmg)) incoming_danger += dmg;
       else{
         incoming_danger = 64;
         break;
      }
   }
   if(incoming_danger > 0){
      do_shutdown_translator();
      do_shutdown_areamap();
   }
}

function processtargets(playerpawn p){
        local pawn t;
        local float d;
        local byte i;
        local int xp, yp;
        local byte radar_cur;
        local vector dir, a, abounds[8], dirbounds[8];
        local bool lock;
        local vector x, y, z;
        local float RadarScanIntervalFloat;
        RadarScanIntervalFloat=0.05;                           // 20 PPS, default
        if(RadarScanInterval>=3) RadarScanIntervalFloat=0.01;  // 100
        if(RadarScanInterval<=1 || !ava_fullscan) RadarScanIntervalFloat=0.1;   // 10
        if(level.timeseconds - decline_timer._rescan < RadarScanIntervalFloat) return;
        decline_timer._rescan = level.timeseconds;
        getaxes(p.viewrotation, x, y, z);
        radar_qty = 0;
        radar_vqty = 0;
        anylock = false;
        if(newfov == 0) newfov = UserSetFOV;  // todo make this automatic. calc necess fov from clipx/clipy ratio
// ====================================================================================== target radar
        foreach RadiusActors(class'pawn', t, RadarScanRadius){
           if(instr(caps(string(t.group)),"AERTARG") == -1 || t.health <= 0) continue;
           a = t.location;
           dir = a - p.location;
           d = vsize(dir);
           dir /= d;
           if((dir dot x) < 0.7) continue;
           if(d > 1024){                                         // rangefinder
              d = fclamp((d - 1024) / 3072, 0, 1);
              radar[radar_qty].r = 255 - (175 * d);     // 2024-08-24: was 225
              radar[radar_qty].g = 255 - (175 * d);
              radar[radar_qty].b = 255 - (175 * d);
           }else{
              d = fclamp((d - 256) / 768, 0, 1);
              radar[radar_qty].r = 255 - 128 * (1-d);
              radar[radar_qty].g = 255 - 220 * (1-d);
              radar[radar_qty].b = 255;
           }
           if(!fasttrace(t.location,p.location)){             // 2025-03-30: behindwall sensor for targets
              radar[radar_qty].g = radar[radar_qty].g >> 4;
              radar[radar_qty].b = radar[radar_qty].b >> 4;
           }
           xp = ( (dir dot y)) * (clipxdiv2 / tan(newfov * pi / 360)) / (dir dot x);
           yp = (-(dir dot z)) * (clipxdiv2 / tan(newfov * pi / 360)) / (dir dot x);
           xp += scale128;
           yp += scale128;
           radar[radar_qty].x=int(xp/scale1);
           radar[radar_qty].y=int(yp/scale1);
           lock = (xp >= -18 * scale1 && xp <= 18 * scale1) && (yp >= -18 * scale1 && yp <= 18 * scale1);
// ====================================================================================== target bounds radar begin
           for(i=0;i<8;i++) abounds[i] = t.location;
           d = t.collisionheight/2;
           for(i=0;i<4;i++) abounds[i].z -= d;
           for(i=4;i<8;i++) abounds[i].z += d;
           d = t.collisionradius/2;
           abounds[0].y -= d; abounds[1].y -= d; abounds[4].y -= d; abounds[5].y -= d;
           abounds[2].y += d; abounds[3].y += d; abounds[6].y += d; abounds[7].y += d;
           abounds[0].x -= d; abounds[3].x -= d; abounds[4].x -= d; abounds[7].x -= d;
           abounds[1].x += d; abounds[2].x += d; abounds[5].x += d; abounds[6].x += d;
           dir = a - p.location;
           d = vsize(dir);
           for(i=0;i<8;i++){
              dirbounds[i] = abounds[i] - p.location;
              dirbounds[i] /= d;
           }
           for(i=0;i<8;i++){
              xp = ( (dirbounds[i] dot y)) * (clipxdiv2 / tan(newfov * pi / 360)) / (dirbounds[i] dot x);
              yp = (-(dirbounds[i] dot z)) * (clipxdiv2 / tan(newfov * pi / 360)) / (dirbounds[i] dot x);
              xp += scale128;
              yp += scale128;
              radarlock[radar_qty].x[i]=int(xp/scale1);
              radarlock[radar_qty].y[i]=int(yp/scale1);
           }
// ====================================================================================== target bounds radar ends
           radar[radar_qty].t=t.name;
           if(radar_qty>=radar_max) continue;
           radar_cur=radar_qty;
           radar_qty++;
           radar[radar_cur].ena=true;
           if(radar[radar_cur].x<5  || radar[radar_cur].x>251 ||
              radar[radar_cur].y<15 || radar[radar_cur].y>245) radar[radar_cur].ena=false;
           if(radar[radar_cur].ena) radar_vqty++;
           if(!lock) continue;
           anylock = true;         // keep an eye on this, if range_targ not set, proirange will access undefined
           range_targ = vsize(t.location - p.location);
        }
}

event RenderOverlays(canvas c){
   if(!canvas_set) calccoords(c);            // for correct radar screen functioning we need to call this at least once
   Texture'aerscreen'.NotifyActor = Self;
   Super.RenderOverlays(c);
   Texture'aerscreen'.NotifyActor = none;    // disabling this let 3rd players see screen, 'Detached client' otherwise
                                             // this feature require multiple unique textures, like sidisptex
   // todo:
   // make std names for scriptedtexture base (sourcetexture), scripted_tmp_texture and use it in all .uc files
   // this will be one universal file for all .uc used as scriptedtexture userpkg template
}

simulated event RenderTexture(ScriptedTexture Tex){
   local string scroll_tmp;
// local playerpawn p;
   local pawn pt;
   local int i, xp,yp, tmi_n,tmi_a,tmi_x,tmi_y,tmi_l;
   local byte j, mb18;
   local color pc, tc;
   local rotator comp_nav,comp_obj;
   local float d;
   local string tmp_string;
   local byte tmp_byte;      // for double ternary repeating calcs
   local int tmp_ammo;
   local bool tmp_bool;
   if(owner == none) return;
   if(!ena_render_scope) return;
// p = playerpawn(owner);    // required for drawportal, or store also owner_rotation (not same as owner_viewrotation)
// if(p == none) return;                              // or maybe destroy owner_viewrotation.pitch
   if(ena_setup){
      RenderSetup(tex);
      return;
   }
// ====================================================================================== EMI shocked
   if(ena_emi){
      rendersnow(tex);
      return;
   }
//   pc = makecolor(255,255,255);                                               // radiation warn
//   tex.DrawTile(0,41,256,233, 0,0,256,256, texture'aerwarnxray', false, pc);
// ====================================================================================== apscan
   goto skip_noapscan;
   if(ena_areamap || ena_translator || ena_fast_shield || !ena_apscan) goto skip_noapscan;
   for(tmi_x=0;tmi_x<apscan_horzres;tmi_x++){
      for(tmi_y=0;tmi_y<apscan_vertres;tmi_y++){
         tmi_l = screenbuffer[tmi_x].data[tmi_y];
         d = tmi_l * 1.0; d *= 200; d /= 256; tmi_n = byte(d);
         tex.DrawTile(0+(tmi_x*16),43+((apscan_vertres-tmi_y-1)*16),(16*1),(16*1), 0,0,4,4,
                      texture'aerpixel', false, makecolor(tmi_n,tmi_n,tmi_l));
      }
   }
   skip_noapscan:
// ====================================================================================== mb portal
//   tex.Draw3DLine(MakeColor(255,0,255),vect(0,0,0),vect(10,10,10));
//   tex.PortalInfo.FOV = newfov;     // 2024-04-14: deleted. contrast looks like shit, terrible idea
//   tex.PortalInfo.RendMap = 5;
//   getaxes(p.rotation,px,py,pz);
//   tex.drawportal(xlevel,p.location+140*px,p.rotation,none); // mb self instead of none
//   tex.DrawPortal(XLevel,Owner.Location+128*vect(0,0,1),rot(-16384,0,0)+Owner.Rotation.Yaw*rot(0,1,0),None); // top view
//   return;
// scopedrifle code:
//   bHidden = True;
//   Tex.DrawPortal(XLevel,PlayerPawn(Owner).Location + (PlayerPawn(Owner).BaseEyeHeight * vect(0,0,1) ),owner_viewrotation);
//   return;
// ====================================================================================== shield notification
//   pc = assign_presence_color(true,100,128,100);
//   if(pw_sens_altfire && ena_fast_shield) tex.DrawTile(0,0,256,256, 0,0,256,256, texture'aershieldbg', false, pc);
// ====================================================================================== forcefield range
   if(state_forcefield[0]==1){
      pc = makecolor(148 + (dist_field[0]/2),255 - (dist_field[0]/2),148);
      tex.DrawTile(2,252-dist_field[0],1,dist_field[0], 0,0,4,4, texture'aerpixel', false, pc);
   }
   if(state_forcefield[1]==1){
      pc = makecolor(148 + (dist_field[1]/2),255 - (dist_field[1]/2),148);
      tex.DrawTile(253,252-dist_field[1],1,dist_field[1], 0,0,4,4, texture'aerpixel', false, pc);
   }
// ====================================================================================== objective distance
   if(ena_objective && !ena_fast_shield && !ena_translator && !ena_areamap){
      pc = assign_presence_color(true, 160,160,255);
      d = vsize(pos_objective - owner_location);             // cancer, d was used for other things.
      tmp_byte = (d <= 470) ? 1 : 0;
      tmp_bool = (tmp_byte > 0);
      if(d <= 48) tmp_byte = 2;
      d *= 0.02125;
      if(tmp_bool) goto skip_obj_range;
      if(d >= 1000.0){
        yp = int(d / 1000);     // before decimal dot
        xp = d - (yp * 1000);   // after
        xp /= 100;
        tmp_string = yp$"."$xp$"km";
      }else{
        yp = int(d);
        tmp_string = yp$"m";
      }
      skip_obj_range:
      pc = tmp_bool ? makecolor(200,255,200) : makecolor(200,200,255);
      if(low_batt || ena_invis) pc = lowbatt_color(pc);
      scroll_tmp = tmp_bool  ? "Dest nearby." : "Dest: "$tmp_string;
      if(tmp_byte == 2) scroll_tmp = "Dest here.";
      tex.drawcoloredtext(4,222,scroll_tmp,font'aerfontsma',pc);
   }
// ====================================================================================== translator message
   pc = makecolor(24,24,24); //64 64 64
   if(ena_translator) pc = makecolor(160,255,160);
    else if(transmsg_proximity && !trans_msg_areasign) pc = makecolor(200,200,255);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   tex.DrawTile(56,239,20,13, 0,0,20,13, texture'aermsg', false, pc);
// ----------------------------------- icon ends, reader code ------------------------
   if(!ena_translator) goto skip_tds_render;
   for(i=0;i<translator_max_rows;i++){
      tmp_string = transmsg_screendata[i];
      xp = instr(tmp_string,"[>");                                            // search for marker
      tmp_bool = (xp > -1);
      if(tmp_bool)
         tmp_string =  left(transmsg_screendata[i],xp) $ "        " $         // erase placeholder with whitespaces
                      right(transmsg_screendata[i],len(transmsg_screendata[i])-xp-8);
    // ----------------------------------- output plaintext if any -----------------------
      pc = assign_presence_color(true,246,218,109);
      tex.drawcoloredtext(7,54+(i*13), tmp_string, font'aerfontsmb',pc);
      if(!tmp_bool) continue;
    // --------------------------------------- parse placeholder -------------------------
      tmi_n = instr(transmsg_coordbar,mid(transmsg_screendata[i],xp+2,1));    // texture number
      if(tmi_n==-1 || tmi_n>7) continue;             // incorrect input coord, abort
      // switch(yp){ textmat = multiskins[yp] }
      transmsg_img_data = texture'aermsgtest';       // todo delete this texture
      if(transmsg_img_data == none) continue;        // texture not set in source actor
      tmi_a = instr(transmsg_coordbar,mid(transmsg_screendata[i],xp+3,1));    // anim length (todo mb anim end?)
      if(tmi_a==-1 || tmi_a>7) continue;                                              // todo check intervals of this
      tmi_x = instr(transmsg_coordbar,mid(transmsg_screendata[i],xp+4,1));    // x texmat coord
      if(tmi_x==-1 || tmi_x>36) continue;
      tmi_y = instr(transmsg_coordbar,mid(transmsg_screendata[i],xp+5,1));    // y texmat coord
      if(tmi_y==-1 || tmi_y>36) continue;
      tmi_l = instr(transmsg_coordbar,mid(transmsg_screendata[i],xp+6,1));    // texmat length
      if(tmi_l==-1 || tmi_l>36) continue;
      tmi_l++;          // counts from 1, not 0
    // ------------------------------------- parse ends, do output -----------------------
      pc = assign_presence_color(true,255,255,255);
      tex.DrawTile(7+xp*7, 54+(13*i), tmi_l*7, 13,   tmi_x*7, tmi_y*13, tmi_l*7, 13,   transmsg_img_data, false, pc);
   }
   skip_tds_render:
//   tex.DrawTile(0,41,256,195, 0,0,256,195, texture'aermsgmsk', true, pc); // this allow observe alpha (set true before pc)
   if(trans_msg_areasign){                                                    // this message is area sign
      pc = assign_presence_color(true,246,218,109); //was 227,186,73);
      for(i=0;i<areasign_max_rows;i++) tex.drawcoloredtext(16,82+(i*29), areasign_screendata[i], font'aerfontbig',pc);
   }
// ====================================================================================== radar dots
   if(!snipe || ena_areamap || ena_translator) goto skip_notarg;
   tmp_byte = ((level.timeseconds-decline_timer._hitsens)>0.1) ? 1 : 0;
   tmp_ammo = 0;
   for(i=0;i<radar_qty;i++){
      if(!radar[i].ena) continue;
      pc = makecolor(radar[i].r,radar[i].g,radar[i].b);
      if(pw_sens_altfire && !ena_fast_shield && (pc.g>=36 && pc.b>=36)) pc = makecolor(255,255,255);
      if(radar[i].hit) pc = (tmp_byte==1) ? makecolor(255,255,32) : makecolor(64,64,255);
      if(low_batt || ena_invis) pc = lowbatt_color(pc);
      for(j=0;j<8;j++) tex.DrawTile(radarlock[i].x[j],radarlock[i].y[j],4,4, 0,0,4,4, texture'aerpixel', false, pc );
//    2024-04-27: lines enclosing abounds to wirefrime box. shit, rendered glitchy
//    for(j=0;j<4;j++){  tmp_byte = j==3 ? 0 : j+1;  connect_dotpair(tex,i,j,tmp_byte,pc);connect_dotpair(tex,i,j,j+4,pc);  }
//    for(j=4;j<8;j++){  tmp_byte = j==7 ? 4 : j+1;  connect_dotpair(tex,i,j,tmp_byte,pc);  }
      //2024-04-15: fly&manta scope assist
      if(radar[i].x<118 || radar[i].x>138 || radar[i].y<118 || radar[i].y>138) continue;
      pt = FindPawn(radar[i].t);
      if(pt == none) continue;
      if(pt.collisionheight>15.0 || pt.collisionradius>30.0 || tmp_ammo!=0) continue;  // show this for first target only
      tmp_ammo = 1;
      tc = assign_presence_color(true,200,255,200);
      if(radar[i].x<128 && !surelock) tex.DrawTile(107,111,2,35,0,0,4,4,texture'aerpixel',false,tc);
      if(radar[i].x>128 && !surelock) tex.DrawTile(148,111,2,35,0,0,4,4,texture'aerpixel',false,tc);
      if(radar[i].y<128 && !surelock) tex.DrawTile(111,107,35,2,0,0,4,4,texture'aerpixel',false,tc);
      if(radar[i].y>128 && !surelock) tex.DrawTile(111,148,35,2,0,0,4,4,texture'aerpixel',false,tc);
   }
   skip_notarg:
// ====================================================================================== crosshair
   if(snipe){
      pc = assign_presence_color(true,32,32,84);
   /* if(surelock){                                                        // old code
         tmp_byte = int(level.timeseconds*25) % 18;                        // lines anim. 25/18 = animtime 1.3888 sec
         tex.DrawTile(19 +(4*tmp_byte), 118,14,1,0,0,4,4,texture'aerpixel',false,pc);
         tex.DrawTile(19 +(4*tmp_byte), 138,14,1,0,0,4,4,texture'aerpixel',false,pc);
         tex.DrawTile(222-(4*tmp_byte), 116,14,1,0,0,4,4,texture'aerpixel',false,pc);
         tex.DrawTile(222-(4*tmp_byte), 138,14,1,0,0,4,4,texture'aerpixel',false,pc);
      }  */
      if(anylock)
         pc = assign_presence_color(true,160,160,160); // 100 100 140
      if(surelock){
         pc = assign_presence_color(true,200,255,200);
         tex.DrawTile(111,107,35,1,0,0,4,4,texture'aerpixel',false,pc);
         tex.DrawTile(111,149,35,1,0,0,4,4,texture'aerpixel',false,pc);
         tex.DrawTile(107,111,1,35,0,0,4,4,texture'aerpixel',false,pc);
         tex.DrawTile(149,111,1,35,0,0,4,4,texture'aerpixel',false,pc);
      }
      tex.DrawTile(111,108,35,1,0,0,4,4,texture'aerpixel',false,pc);
      tex.DrawTile(111,148,35,1,0,0,4,4,texture'aerpixel',false,pc);
      tex.DrawTile(108,111,1,35,0,0,4,4,texture'aerpixel',false,pc);
      tex.DrawTile(148,111,1,35,0,0,4,4,texture'aerpixel',false,pc);
   }
// ====================================================================================== compass
// todo: MOVE compass related to timer()
// todo: all geom calcs in timer.
// todo: do not calc in renderproc.
// todo: make universal function                            // todo put this in if too
   comp_nav = owner_viewrotation;                           comp_obj = rotator(pos_objective - owner_location);
   comp_nav.yaw = comp_nav.yaw % 65536;                     comp_obj.yaw = comp_obj.yaw % 65536;
   comp_nav.pitch = comp_nav.pitch % 65536;                 comp_obj.pitch = comp_obj.pitch % 65536;
   if(comp_nav.pitch <  65536)   comp_nav.pitch += 65536;   if(comp_obj.pitch <  65536) comp_obj.pitch += 65536;
   if(comp_nav.pitch >  65536)   comp_nav.pitch -= 65536;   if(comp_obj.pitch >  65536) comp_obj.pitch -= 65536;
   if(comp_nav.pitch >  32768)   comp_nav.pitch -= 65536;   if(comp_obj.pitch >  32768) comp_obj.pitch -= 65536;
   if(comp_nav.yaw   >  32768)   comp_nav.yaw   -= 65536;   if(comp_obj.yaw   >  32768) comp_obj.yaw   -= 65536;
   if(comp_nav.yaw   < -32768)   comp_nav.yaw   += 65536;   if(comp_obj.yaw   < -32768) comp_obj.yaw   += 65536;
   // ---------------------------------------------------- navigation compass
   if(comp_nav.pitch < 0){ d = -comp_nav.pitch;  d = d / 16384 * 110;  yp = 128 + int(d); }
                     else{ d =  comp_nav.pitch;  d = d / 18000 * 110;  yp = 128 - int(d); }
                           d =  comp_nav.yaw;    d = d / 32768 * 120;  xp = 128 + int(d);
   pc = assign_presence_color(true,255,255,255);
   tex.DrawTile(251,yp,4,2,0,0,4,4,texture'aerpixel',false,pc); //vert
   tex.DrawTile(xp,251,2,4,0,0,4,4,texture'aerpixel',false,pc); //horz
   // ---------------------------------------------------- objective compass
   if(ena_objective){
      if(comp_obj.pitch < 0){ d = -comp_obj.pitch;  d = d / 16384 * 110;  yp = 128 + int(d); }
                        else{ d =  comp_obj.pitch;  d = d / 18000 * 110;  yp = 128 - int(d); }
                              d =  comp_obj.yaw;    d = d / 32768 * 120;  xp = 128 + int(d);
      pc = assign_presence_color(true, 160,160,255);
      tex.DrawTile(251,yp,4,2,0,0,4,4,texture'aerpixel',false,pc); //vert
      tex.DrawTile(xp,251,2,4,0,0,4,4,texture'aerpixel',false,pc); //horz
   }
// ====================================================================================== ammo chg dots
   tmp_ammo = 0;
   if(ammo_chg < power_chg) tmp_ammo = power_chg - ammo_chg;
   pc = (ammo_chg == 0) ? makecolor(70,30,30) : makecolor(47,47,70);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   for(i=0;i<tmp_ammo;i++)
      tex.DrawTile(1+i*4,2,2,6, 0,0,4,4, texture'aerpixel', false, pc);
   // ---------- old code, do not change
   tmp_byte = power_chg <= 4 ? 160 : 220;
   pc = power_chg <= 12 ? makecolor(255,tmp_byte,64) : makecolor(255,255,255);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   for(i=tmp_ammo;i<power_chg;i++)
      tex.DrawTile(1+i*4,2,2,6, 0,0,4,4, texture'aerpixel', false, pc);
   pc = power_chg > 0 ? makecolor(32,32,32) : makecolor(255,64,64);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   for(i=0;i<(power_max_top-power_chg);i++)
      tex.DrawTile(1+((power_max_top-i)*4)-4,2,2,6, 0,0,4,4, texture'aerpixel', false, pc);
// ====================================================================================== synth chg dots
   if(ena_synth){
      pc = assign_synth_color(2); tex.DrawTile(220,2,4,6, 0,0,4,4, texture'aerpixel', false, pc);
      pc = assign_synth_color(3); tex.DrawTile(228,2,4,6, 0,0,4,4, texture'aerpixel', false, pc);
      pc = assign_synth_color(4); tex.DrawTile(236,2,4,6, 0,0,4,4, texture'aerpixel', false, pc);
      pc = assign_synth_color(5); tex.DrawTile(244,2,4,6, 0,0,4,4, texture'aerpixel', false, pc);
   }
// ====================================================================================== fast shield state+chg
   if(ena_fast_shield){
      tmp_byte = clamp(fast_shield_chg,0,255);
      pc = assign_presence_color(true, 100,100,132);  // 2024-04-18: diff color while active, deleted - annoys when use airpush
      tex.DrawTile(0,237,tmp_byte,1, 0,0,4,4, texture'aerpixel', false, pc);
      pc = assign_presence_color(true, 255,255,160);
      tex.DrawTile(0+tmp_byte,237,populated_shield_dmg,1, 0,0,4,4, texture'aerpixel', false, pc);
      if(!pw_sens_altfire){
         pc = assign_presence_color(true, 100,132,100);
         tex.DrawTile(0+tmp_byte+populated_shield_dmg,237,1,1, 0,0,4,4, texture'aerpixel', false, pc);
      }
   }else{
      tmp_bool = ((int(level.timeseconds*10) % 20) >= 4);
      pc = tmp_bool ? makecolor(255,100,100) : makecolor(255,255,255);
      if(low_batt || ena_invis) pc = lowbatt_color(pc);
      tex.DrawTile(0,237,255,1, 0,0,4,4, texture'aerpixel', false, pc);
   }
// ====================================================================================== monitor text, rangefinder and zoom
   pc = assign_presence_color(true, 160,160,255);
   if(range>=32941) tmp_string="O.L."; else tmp_string=int(range*0.02125)$"m";     // 700m max  // mb .02275
   if(!ena_laser) tmp_string="n/a";
      else if(inhibit_laser) tmp_string="O.L.";
   tmp_string = "Rng: "$tmp_string;
   if(low_batt){
      pc = assign_presence_color(true, 255,160,160);
      tmp_string = "Low batt";
   }
   if(ena_invis) tmp_string = "Stealth";
   if(incoming_danger == 0) tex.drawcoloredtext(1,12,tmp_string,font'aerfontsma',pc);
   pc = assign_presence_color(true, 160,160,255);
   if(ena_translator || ena_areamap){
      pc = assign_presence_color(true, 160,255,160);
      tmp_string = "Msg[   ]";
      goto skip_zoom_check;
   }
   if(!ena_fast_shield){
      if(zoomfactor > 1) pc = assign_presence_color(true, 220,220,255);
      tmp_string = "ZF: "$string(zoomfactor)$"00%";
   }else{
      tmp_string = "AR mode";
   }
   skip_zoom_check:
   if(ena_areamap) tmp_string = "Area map";
   tex.drawcoloredtext(1,27,tmp_string,font'aerfontsma',pc);
   if(!ena_translator || ena_areamap) goto skip_msg_control;
   if(tds_oper==0){
      if(transmsg_remain_scroll == 0) pc = assign_presence_color(true, 255,255,255);    // keep SEL green, if scrollable
      tex.drawcoloredtext(29,27,"SEL",font'aerfontsma',pc);
   }else{
      tmi_n = transmsg_applied_scroll + transmsg_remain_scroll;
      tmi_a = transmsg_applied_scroll;
      if(tmi_a > tmi_n) tmi_a = tmi_n;
      if(tmi_a == 0) tmi_a = 1;
      d = float(tmi_a);
      d /= tmi_n;
      d *= 100;
      tmp_byte = clamp(d, 1, 99);
      tmp_string = string(tmp_byte);
      if(tmp_byte < 10) tmp_string = " " $ tmp_string;
      tmp_string $= "%";
      tex.drawcoloredtext(29,27,tmp_string,font'aerfontsma',pc);
   }
   skip_msg_control:
// ====================================================================================== aux oper
   mb18 = !ena_cloak ? 18 : 0;
   pc = assign_state_color(ena_laser,             ava_laser, 200,200,255);              tex.drawcoloredtext(167+mb18,239,"LP",font'aerfontsma',pc);
   pc = assign_state_color(state_forcefield[0]==1,ava_ffield,200,200,255,boost_power);  tex.drawcoloredtext(185+mb18,239,"F1",font'aerfontsma',pc);
   pc = assign_state_color(state_forcefield[1]==1,ava_ffield,200,200,255,boost_power);  tex.drawcoloredtext(203+mb18,239,"F2",font'aerfontsma',pc);
   if(!ena_cloak) goto skip_cd_stat;
   pc = assign_state_color(ena_invis,             ava_invis, 200,200,255);              tex.drawcoloredtext(221,     239,"ST",font'aerfontsma',pc);
   skip_cd_stat:
   pc = assign_state_color(level.timeseconds - decline_timer._repush < PushInterval,
                                                  true,      255,255,160);               tex.drawcoloredtext(239,     239,"VI",font'aerfontsma',pc);
   pc = assign_presence_color(true,200,200,255);
   d = level.timeseconds - decline_timer._reclick;                              // shithack, d was used above
   if(pw_sens_altfire && d >= RClickChgModeMin && d < RClickChgModeMax)       pc = assign_presence_color(true,255,0,0);
   if(pw_sens_altfire && d >= RClickExecAltCmdMin && d < RClickExecAltCmdMax) pc = assign_presence_color(true,0,255,255); // exec alt
   j = 167 + (aux_oper*18) + mb18;  // j = fabricated x coord, mb18 = maybe 18px offset
   if(aux_oper >= 3) j -= mb18;
   tex.DrawTile(j,252,14,1, 0,0,4,4, texture'aerpixel', false, pc);
 /*if(aux_oper==0) tex.DrawTile(167+mb18,252,14,1, 0,0,4,4, texture'aerpixel', false, pc);  // old aux selector code
   if(aux_oper==1) tex.DrawTile(185+mb18,252,14,1, 0,0,4,4, texture'aerpixel', false, pc);
   if(aux_oper==2) tex.DrawTile(203+mb18,252,14,1, 0,0,4,4, texture'aerpixel', false, pc);
   if(aux_oper==3) tex.DrawTile(221,     252,14,1, 0,0,4,4, texture'aerpixel', false, pc);
   if(aux_oper==4) tex.DrawTile(239,     252,14,1, 0,0,4,4, texture'aerpixel', false, pc);*/
// ====================================================================================== ammo counter
   tmp_byte=0;
   if(ammo_chg < 100){ tmp_string = "0"; tmp_byte = 1; }
   if(ammo_chg< 10){  tmp_string = "00"; tmp_byte = 2; }
   if(tmp_byte > 0){
      pc = makecolor(32,32,32);
      if(low_batt || ena_invis) pc = lowbatt_color(pc);
      tex.drawcoloredtext(205,14,tmp_string,font'aerfontbig',pc);
   }
   pc.r = ammo_chg>80 ? 200 : 255;
   pc.g = ammo_chg>40 ? 255 : 200;
   pc.b = 200;
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   tmp_string = string(ammo_chg);
   tex.drawcoloredtext(205+(16*tmp_byte),14,tmp_string,font'aerfontbig',pc);
// ====================================================================================== rssi counter
   pc = assign_presence_color(true,150,150,192);
   for(i=0;i<modem_rssi;i++) tex.DrawTile(4+(i*3),247-i,2,3+i, 0,0,4,4, texture'aerpixel', false, pc);
   pc = assign_presence_color(true,45,45,45);
   for(i=modem_rssi;i<6;i++) tex.DrawTile(4+(i*3),247-i,2,3+i, 0,0,4,4, texture'aerpixel', false, pc);
// tex.DrawTile(4 ,247,2,3, 0,0,4,4, texture'aerpixel', false, pc);  // old code
// tex.DrawTile(7 ,246,2,4, 0,0,4,4, texture'aerpixel', false, pc);
// tex.DrawTile(10,245,2,5, 0,0,4,4, texture'aerpixel', false, pc);
// tex.DrawTile(13,244,2,6, 0,0,4,4, texture'aerpixel', false, pc);
// tex.DrawTile(16,243,2,7, 0,0,4,4, texture'aerpixel', false, pc);
// tex.DrawTile(19,242,2,8, 0,0,4,4, texture'aerpixel', false, pc);
// ====================================================================================== batt counter
   pc = assign_presence_color(true,200,200,255);
   tmp_byte = clamp(batt_chg/batt_min_one, 1, 99);
// tex.drawcoloredtext(4,229,"CR: "$batt_chg,font'aerfontsma',pc); // debug, raw batt
   if(low_batt) tmp_byte = 0;
   tex.drawcoloredtext(28,239,tmp_byte$"%",font'aerfontsma',pc);
// ====================================================================================== penetrability monitor
   for(i=0;i<penmon_capacity;i++){                                           // penetrability
      if(penetrability_monitor[i]._full == 0) continue;
      tmp_bool = (penetrability_monitor[i]._rem == 0);
      tmp_byte = tmp_bool ? 2 : penetrability_monitor[i]._full;
      pc = tmp_bool ? assign_presence_color(true,210,140,210) : assign_presence_color(true,110,110,230);
      tex.DrawTile(65+(i),38-penetrability_monitor[i]._full,2,tmp_byte, 0,0,4,4, texture'aerpixel', false, pc);
   }
   for(i=0;i<penmon_capacity;i++) if(penetrability_monitor[i]._admg > 0){    // death/corpse detect
      if(penetrability_monitor[i]._admg < 40) continue;
      pc = (penetrability_monitor[i]._admg == 50) ? assign_presence_color(true,255,60,60) : assign_presence_color(true,120,255,120);
      tex.DrawTile(65+(i),38-25,  2,2,  0,0,4,4, texture'aerpixel', false, pc);
   }
   pc = assign_presence_color(true,40,40,64);
   for(i=0;i<penmon_capacity;i++)
      tex.DrawTile(65+(i),38-penetrability_monitor[i]._rem, 2,penetrability_monitor[i]._rem,  0,0,4,4, texture'aerpixel', false, pc);
   pc = assign_presence_color(true,255,255,200);                // pain graph
   for(i=0;i<penmon_capacity;i++) if(penetrability_monitor[i]._admg > 0){
      if(penetrability_monitor[i]._admg == 40 || penetrability_monitor[i]._admg == 50) continue;
      tex.DrawTile(65+(i),38-clamp(penetrability_monitor[i]._admg,0,25),2,2,  0,0,4,4, texture'aerpixel', false, pc);
   }
   pc = assign_presence_color(true,80,80,128);                  // zero line
   tex.DrawTile(60,38,(penmon_capacity)+5,1, 0,0,4,4, texture'aerpixel', false, pc);
// ====================================================================================== other statusbar indicators
   pc = assign_presence_color(surelock,200,255,200);            // 2024-01-20: removed surelock animation,
// pc = assign_presence_color(anylock,200,255,200);             // LOCK now triggers only by laser
   tmp_string = "LOCK";
   if(hdmlock){
      tmp_string = " HDM";
      pc = assign_presence_color(true,255,158,84);
   }  // maybe other matsensor reports here
   tex.drawcoloredtext(63+19,239,tmp_string,font'aerfontsma',pc);
   pc = assign_presence_color(sensed_forcefield_attractor != none,255,200,255);
   tex.drawcoloredtext(95+19,239,"EMR",font'aerfontsma',pc);
   pc = assign_presence_color(boost_power,255,255,200);
   tex.drawcoloredtext(120+19,239,"PWR",font'aerfontsma',pc);
/* if(ena_synth){                                   // 2024-05-19: deleted. stupid feature + no room in status line
      tc = !low_repower ? makecolor(200,220,255) : makecolor(160,60,60);
      pc = assign_presence_color(ava_synth,tc.r,tc.g,tc.b);
      tex.drawcoloredtext(145,239,"Td",font'aerfontsma',pc);
   }  */
// ====================================================================================== area map
   if(ena_areamap){
      render_areamap(tex);     // todo set pn.bDirectional as discover flag. introduce discovertrigger.
//    render_areamap_new(tex);
      return;
   }
// ====================================================================================== failed forcefield indicator
   if(warn_opermsg && !ena_translator && !ena_areamap){
      pc = assign_presence_color(true,255,200,255);
      tex.drawcoloredtext(26,180,aux_oper_msg[0],font'aerfontsma',pc);
      tex.drawcoloredtext(28,195,aux_oper_msg[1],font'aerfontsma',pc);
   }
// ====================================================================================== incoming danger indicator
   if(incoming_danger>0){
      pc = makecolor(255,255,255);
      tex.drawcoloredtext(1,12,"Incoming danger",font'aerfontsma',pc);
      pc = makecolor(55,55,64);
      tex.DrawTile(0,41,256,3, 0,0,4,4, texture'aerpixel', false, pc);
      tmp_bool = (int(level.timeseconds*11) % 2)==0;
      pc = tmp_bool ? makecolor(220,220,255) : makecolor(255,32,32);
      tex.DrawTile(0,                    41,incoming_danger*4,3, 0,0,4,4, texture'aerpixel', false, pc);
      tex.DrawTile(255-incoming_danger*4,41,incoming_danger*4,3, 0,0,4,4, texture'aerpixel', false, pc);
   }
// ====================================================================================== shield related warnings color
   if(!ena_fast_shield) return;
   tmp_bool = (int(level.timeseconds*9) % 2)==0;
   pc = tmp_bool ? makecolor(255,75,75) : makecolor(200,200,255);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
// ====================================================================================== shield related warnings output
   if(pw_sens_altfire && pw_sens_fire && fast_shield_chg >= 1)
                                              tex.drawcoloredtext(9, 180,"Can't fire while shield is active.",font'aerfontsma',pc);
   if(pw_sens_altfire && fast_shield_chg<1 && state_forcefield[0]!=1 && state_forcefield[1]!=1)
                                              // 2025-04-24: see do_tick_shield_capacitor()
                                              tex.drawcoloredtext(47,180,"Shield capacitor empty.",font'aerfontsma',pc);
   if(!warn_aux) return;
   tex.DrawTile(1,40,50,1, 0,0,4,4, texture'aerpixel', false, pc);
}

function render_areamap_new(scriptedtexture tex){     //256x196 from 0,41
   local playerpawn p;
   local float rotr;  // radians rotation
   local float user_z;
   local int   disp_w,   disp_h,   // screen vars, full w/h
               disp_hw,  disp_hh,  //   half w/h
               disp_ox,  disp_oy,  //   UI offset
               user_x,   user_y,   // truncd. user@world coords
               prn_tlx,  prn_tly,  // print begin
               prn_brx,  prn_bry,  // "end" (runlength)
               pbi_w,    pbi_h,    // insuff of beg
               pei_w,    pei_h;    // insuff of end
   local bool  dimmed_bg,          // false = output z-match maps only
                                   // true  = output all maps
               is_relevant;
   local color pc;
   local byte  nmarker,i,k;
   local areamapdata amd;                        // mb todo make this global
   if(owner!=none) p = playerpawn(owner);
   if(p == none) return;
   amd = FindAMD();
   if(amd == none){
      pc = assign_presence_color(true,246,218,109);
//      pc = assign_presence_color(true,200,200,255);
      tex.drawcoloredtext(70,130,"Area is unknown.",font'aerfontsmb',pc);
      return;
   }
   disp_ox = 0;    disp_w = 256;  disp_hw = (disp_w>>1);      // setup disp
   disp_oy = 41;   disp_h = 196;  disp_hh = (disp_h>>1);
//------- map, twopass -------------------------------------------------------------------
   dimmed_bg = true;
   for(k=0;k<2;k++){
      if(k==0)                    // 1st pass
         pc = assign_presence_color(true,50,50,64);
      if(k>=1){                   // 2nd pass
         pc = assign_presence_color(true,200,200,255);
         dimmed_bg = false;
      }
      for(i=0;i<63;i++){                                   // todo mb 1st pass show tex[0], then single z-match. less drawcalls
                                                           // todo  reqiure merged tex for these coords, or "single z" indicator
         if(amd.MapTex[i] == none) continue;  // mb break here
         user_z = p.location.z % 128;
         user_z = p.location.z - user_z;
         is_relevant = (abs(user_z - amd.AreaZ[i]) <= 128);
         if(!dimmed_bg && !is_relevant) continue;
         user_x = int(p.location.x) >> amd.SHR_factor;
         user_y = int(p.location.y) >> amd.SHR_factor;
         prn_tlx = user_x; prn_tlx += (amd.AlignX[i] >> amd.SHR_factor); prn_tlx += (amd.MapTex[i].Usize>>1); prn_tlx -= disp_hw;
         prn_tly = user_y; prn_tly += (amd.AlignY[i] >> amd.SHR_factor); prn_tly += (amd.MapTex[i].Vsize>>1); prn_tly -= disp_hh;
         pbi_w = 0; prn_brx = disp_w; if(prn_tlx<0){ pbi_w += prn_tlx; prn_brx += prn_tlx; prn_tlx = 0;} if(prn_brx<=0) continue;
         pbi_h = 0; prn_bry = disp_h; if(prn_tly<0){ pbi_h += prn_tly; prn_bry += prn_tly; prn_tly = 0;} if(prn_bry<=0) continue;
         pei_w = amd.MapTex[i].Usize - prn_tlx; pei_w -= disp_w; if(pei_w<0) prn_brx += pei_w; if(prn_brx<=0) continue;
         pei_h = amd.MapTex[i].Vsize - prn_tly; pei_h -= disp_h; if(pei_h<0) prn_bry += pei_h; if(prn_bry<=0) continue;
         tex.DrawTile(disp_ox-pbi_w, disp_oy-pbi_h, prn_brx,prn_bry, prn_tlx,prn_tly, prn_brx,prn_bry, amd.MapTex[i], true, pc);
      }
   }
//------- player pos marker --------------------------------------------------------------
   pc = assign_presence_color(true,200,255,200);
   rotr = (p.viewrotation.yaw+16384) % 65536;    // -90 because zero yaw in unrealed is A of WASD
   if(rotr < 0) rotr += 65536;
   nmarker = byte(rotr/2730.66);
   tex.DrawTile(119,129,16,16, nmarker*16,0, 16,16, texture'aerbearing', true, pc);    
}

function render_areamap(scriptedtexture tex){   // realtime raytracing areamap, don't need data actors, slower
   local vector x,y,z,endtrace,hl,hn,hl_tmp;
   local rotator r;
   local float rotr;  // radians rotation
   local pathnode pn;
   local int hlx,hly;
   local pawn p;
   local byte i;
   local int nmarker; //_lbx,marker_lby,marker_lex,marker_ley;  // line begin/end x/y
   local color pc,tc;
   if(!validate_owner_toggle()) return;
//----- show dimmed bg ---------------
   foreach allactors(class'pathnode',pn){  // was radiusactors 4096 max  // todo abuse possible: while areamap, RMB wont eat shieldchg
      if(!pn.bDirectional) continue;
      hl = pn.location - owner_location;
//    if(abs(hl.x) > 4288 || abs(hl.y) > 3232) continue;        // 16uu/pixel (zoom level variants)
      if(abs(hl.x) > 2144 || abs(hl.y) > 1560) continue;        // 8uu/pix
//    if(abs(hl.x) > 2336 || abs(hl.y) > 1752) continue;        // 8uu/pix, attempt to prevent screen edges flicker
//    pc = (abs(hl.z) < 80) ? makecolor(200,200,255) : makecolor(32,32,40); // old code

//    pc = (abs(hl.z) < 80) ? makecolor(255,255,255) : makecolor(110,110,160);    // old
      pc = (abs(hl.z) < 80) ? makecolor(255,255,255) : makecolor(50,50,64);    // new, same as texmap

      hl = owner_location;
      hl_tmp = hl;
      rotr = level.timeseconds - int(level.timeseconds);        // variant 1, timebased scanning
//      r.yaw = int(rotr * 65536 * 50);
    r.yaw = 0;                                                // variant 2, static picture, slower, noflicker
//    r.yaw = 1100;
      r.roll = 0; r.pitch = 0;
      for(i=0;i<64;i++){ // was 16 for livescan
         tc = pc; // save thisheight color
         getaxes(r,x,y,z); endtrace = pn.location + 512.0 * x;
         trace(hl,hn,endtrace,pn.location,true);  // todo determine mover
         // if(mover) tc = red;
         if(low_batt || ena_invis) pc = lowbatt_color(pc);  // todo decide with invis, imo enable enter it
         hl_tmp = hl;
         hl_tmp -= owner_location;
         hlx = (hl_tmp.x >> 4);  // 3=zoomin 1072 xmax pn, 5=zoomout 4288 xmax
         hly = (hl_tmp.y >> 4);
//         hlx /= _scroll; hly /= _scroll;  // variable zoom
         hlx+=128;
         hly+=97; hly+=41;
         if(hlx<0 || hlx>255 || hly<41 || hly>236) continue;
         tex.DrawTile(hlx,hly,1,1, 0,0,4,4, texture'aerpixel', false, tc);
//         r.yaw+=8192;   // was 1365, 48 rays/2pi; rays = 65536/yawdelta
         r.yaw+=1024;   // was 1365, 48 rays/2pi; rays = 65536/yawdelta
      }
   }
//------- radar targets ------------------------------------------------------------------
   foreach allactors(class'pawn',p){
      if(instr(caps(string(p.group)),"AERTARG") == -1 || p.health <= 0) continue;
      hl_tmp = p.location;
      hl_tmp -= owner_location;
      hlx = (hl_tmp.x >> 4);
      hly = (hl_tmp.y >> 4);
      hlx+=126;
      hly+=95; hly+=41;
      if(hlx<2 || hlx>253 || hly<43 || hly>234) continue;
      tex.DrawTile(hlx,hly,4,4, 0,0,4,4, texture'aerpixel', false, makecolor(255,120,120));
   }
//------- player pos marker --------------------------------------------------------------
   pc = assign_presence_color(true,200,255,200);
   rotr = (owner_viewrotation.yaw+16384) % 65536;    // -90 because zero yaw in unrealed is A of WASD
   if(rotr < 0) rotr += 65536;
   nmarker = byte(rotr/2730.66);
   tex.DrawTile(119,129,16,16, nmarker*16,0, 16,16, texture'aerbearing', true, pc);    
//----------------------------------------------------------------------------------------
}

function do_tick_scan_rssi(){
   local pathnode pn,pn_act;
   local float dist,dist_act;
   if(level.timeseconds - decline_timer._rerssi < 0.7) return;
   decline_timer._rerssi = level.timeseconds;
   modem_rssi = 0;
   dist_act = 1025.0;
   foreach radiusactors(class'pathnode',pn,384){
      if(!pn.bDirectional) pn.bDirectional = true;  // enable renderpoint for areamap_discovery
//      pn.bHidden = false;
      dist = vsize(owner_location - pn.location);
      if(dist < dist_act){
         dist_act = dist;
         pn_act = pn;
      }
   }
   if(pn_act==none && pn!=none) pn_act = pn;
   if(pn_act==none) return;
   modem_rssi = byte(right(string(pn_act.group),1));   // group named rssi0-rssi6
}

function rendersnow(scriptedtexture tex){
   local byte i,j,k,l;
   local color pc;
   pc = makecolor(0,0,0);
   tex.DrawTile(0,0,256,256, 0,0,4,4, texture'aerpixel', false, pc);
   pc = !low_batt ? makecolor(255,255,255) : makecolor(64,64,64);
   for(i=0;i<128;i++){
      i+=rand(6);
      k=rand(4);
      if(k==0) l=12;
      if(k==1) l=22;
      if(k==2) l=30;
      if(k==3) l=44;
      for(j=0;j<rand(4);j++) tex.DrawTile(rand(300)-44,i*2,l,2, 0,0,4,4, texture'aerpixel', false, pc);
   }
}
/*  2024-08-20: deleted because unused
function connect_dotpair(scriptedtexture tex,byte n_set,byte n_sta,byte n_end,color pc){
   if(!usable_dot(radarlock[n_set].x[n_sta],radarlock[n_set].y[n_sta])) return;
   if(!usable_dot(radarlock[n_set].x[n_end],radarlock[n_set].y[n_end])) return;
   st_line(tex, radarlock[n_set].x[n_sta],radarlock[n_set].y[n_sta],radarlock[n_set].x[n_end],radarlock[n_set].y[n_end],pc);
}

function bool usable_dot(byte x_sta, byte y_sta){
   if(x_sta<5 || x_sta>250) return false;
   if(y_sta<5 || y_sta>250) return false;
   return true;
}

function st_line(scriptedtexture tex, byte x_sta, byte y_sta, byte x_end, byte y_end, color pc){
   local int sign_x,sign_y,delta_x,delta_y;
   local float slope,pitch;
   if (x_sta == x_end && y_sta == y_end) {
     tex.DrawTile(x_sta,y_sta,1,1,0,0,4,4,texture'aerpixel',false,pc);
     return;
   }
   delta_x = x_end - x_sta;
   if (delta_x < 0) sign_x = -1;
    else sign_x = 1;
   delta_y = y_end - y_sta;
   if (delta_y < 0) sign_y = -1;
    else sign_y = 1;
   if (abs(delta_y) < abs(delta_x)) {
      slope = delta_y / delta_x;
      pitch = y_sta - slope * x_sta;
      while (x_sta != x_end) {
         tex.DrawTile(x_sta,byte(slope * x_sta + pitch),1,1,0,0,4,4,texture'aerpixel',false,pc);
         x_sta += sign_x;
      }
   }else{
      slope = delta_x / delta_y;
      pitch = x_sta - slope * y_sta;
      while (y_sta != y_end) {
         tex.DrawTile(byte(slope * y_sta + pitch),y_sta,1,1,0,0,4,4,texture'aerpixel',false,pc);
         y_sta += sign_y;
      }
   }
   tex.DrawTile(x_end, y_end,1,1,0,0,4,4,texture'aerpixel',false,pc);  // last pixel, mbshit
}
*/
function color lowbatt_color(color pc){
   pc.r = pc.r>>2;
   pc.g = pc.g>>2;
   pc.b = pc.b>>2;
   return pc;
}

function color assign_state_color(bool vstate, bool avail, byte ac_r, byte ac_g, byte ac_b, optional bool power_src){
   local color pc;
   local byte g_tmp,b_tmp;
   if(!avail) goto nopower;
   g_tmp = power_src ? 128 : 64;         // idle F1 F2 icons are greener when boost_power
   b_tmp = power_src ? 112 : 64;
   pc = vstate ? makecolor(ac_r,ac_g,ac_b) : makecolor(64,g_tmp,b_tmp);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   return pc;
   nopower:
   pc = vstate ? makecolor(ac_r,ac_g,ac_b) : makecolor(160,60,60);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   return pc;
}

function color assign_presence_color(bool pstate, byte ac_r, byte ac_g, byte ac_b){
   local color pc;
   pc = pstate ? makecolor(ac_r,ac_g,ac_b) : makecolor(24,24,24);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   return pc;
}

function color assign_synth_color(byte c_pos){
   local color pc;
   pc = makecolor(32,32,32);
   if(synth_chg>=synth_max){
     pc = makecolor(150,150,255);
     if(low_batt || ena_invis) pc = lowbatt_color(pc);
     return pc;
   }
   if(synth_chg>=c_pos) pc = makecolor(170,255,170);
   if(low_batt || ena_invis) pc = lowbatt_color(pc);
   return pc;
}

// ====================================================================================== BIOS
function RenderSetup(scriptedtexture Tex){
   local color pc;
   local string setup_activity,err_first,err_second;
   local bool initfail,seq_hello_lower_19;
   local byte maxdiagframe,i;
   pc = makecolor(255,255,200);
   initfail = setup_room_qc < 6;
   maxdiagframe = !initfail ? 6 : 29;
   seq_hello_lower_19 = seq_hello <= 19;
   setup_activity = "";
   if( seq_hello >= 4  && seq_hello_lower_19)              setup_activity = "Diag CTL entity...";
   if( seq_hello >= 6  && !initfail)                       setup_activity = "Booting setup...";
   if((seq_hello >= 7  && seq_hello_lower_19) && initfail) err_first      = "Failed.";
   if((seq_hello >= 10 && seq_hello_lower_19) && initfail) err_second     = "Consider go outside for more room.";
   if((seq_hello >= 20 && seq_hello <= 29)    && initfail) err_second     = "Destructing existing entities...";
   if( seq_hello >= 3  && seq_hello <= maxdiagframe)  tex.drawcoloredtext(2,2,"AER BIOS online. "$setup_activity,font'aerfontsma',pc);
   if( seq_hello >= 7  && seq_hello <= maxdiagframe){
     tex.drawcoloredtext(2,15, err_first,font'aerfontsma',pc);
     tex.drawcoloredtext(2,28, err_second,font'aerfontsma',pc);
   }
   if((initfail && seq_hello <= 32) || (!initfail && seq_hello <= 8)) return;
   pc.b=255;
   tex.drawcoloredtext(2,2,  "- AER CMOS setup utility -----------"$seq_hello,font'aerfontsma',pc);
   if(seq_hello <= 30){
      err_first="";                        // shithack, this var used earlier
      for(i=0; i<(seq_hello>>1); i++) err_first $= ".";
      tex.drawcoloredtext(2,28, "Starting "$err_first,font'aerfontsma',pc);
      return;
   }
   pc.g=200;
   tex.drawcoloredtext(2,28, setup_menu_hdr,font'aerfontsma',pc);
   pc.g=255;
   pc.b=200;
   for(i=0; i<7; i++){
      pc.r = cmos_sel == i ? 160 : 255;
      tex.drawcoloredtext(2,54+i*13, setup_menu_line[i],font'aerfontsma',pc);
   }
}

function TweenDown(){
   bOwnsCrosshair = true;         // todo wtf bownscrosshair is true?
   bMyOwnsCrosshair = false;
   collapse_shield();
   if(playerpawn(owner) == none) return;
   newfov = initial_fov;
   playerpawn(owner).mousesensitivity = initial_mousesens;
   ambientsound=none;
}

function float RateSelf(out int busealtmode){
   return 2;
}

function setHand(float Hand){
   if(hand == 1)  playerviewoffset.y = -880; // was -350;
   if(hand == -1) playerviewoffset.y = -280; // was  250;
}

function PlayFiring(){}

function attempt_tag_target(pawn targ){
   local scriptedpawn tmp_sp;
   if(instr(caps(string(targ.group)),"AERTARG") != -1) return;
   if(targ==owner) return;
   if(targ.health <= 0){
           targ.group = '';
           return;
   }
   if(bool(flockpawn(targ)) || bool(flockmasterpawn(targ)) || bool(nali(targ)) || bool(cow(targ))) return;
   if(targ.isa('stationarypawn') || targ.isa('cspawn') || targ.isa('upakintermissioncam')) return;
   if(targ.AttitudeToPlayer<ATTITUDE_IGNORE) targ.group = 'AERTARG';
   tmp_sp = scriptedpawn(targ);
   if(tmp_sp == none) return;
   if(tmp_sp.bHateWhenTriggered) targ.group = 'AERTARG';
}

function do_hitsens_clr(){
   local byte i;
   if(ignore_hitsens_rst) return;
   if(level.timeseconds-decline_timer._hitsens<0.2) return;
   for(i=0;i<radar_max;i++) radar[i].hit=false;
   ignore_hitsens_trig=false;
   ignore_hitsens_rst=true;
}

function do_hitsens_set(){
   local byte i;
   if(ignore_hitsens_trig) return;
   for(i=0;i<radar_qty;i++){
      if(!radar[i].hit) continue;
      ignore_hitsens_rst=false;
      ignore_hitsens_trig=true;
      decline_timer._hitsens=level.timeseconds;
   }
}

function do_objective_set(){
   local float d;
//   if(ena_objective) return;
   d = vsize(pos_objective - owner_location);
   if(d > 470 || snipe) return;
   aerwhere();
}

function do_objective_clr(){
   if(!ena_objective) return;
   if(snipe){
      ena_objective = false;
      return;
   }
   if(level.timeseconds - decline_timer._unobj <= 8.0) return;
   ena_objective = false;
}

exec function AERToggleTRanslator(){
   if(!validate_owner_toggle()) return;
   if(trans_msg_areasign) return;
   ena_translator = !ena_translator;
   if(ena_translator){
      ena_areamap = false;
      transmsg_applied_scroll = 0;
      query_trans_msg_data();
   }
   if(transmsg_receiver == none) return;
   transmsg_receiver.bNewMessage = false;
   if(!ena_translator) transmsg_receiver.forget_nosave();
}

function query_trans_msg_data(){
   local string msg_raw;
   local translatorevent t;
   local int k;
   if(transmsg_receiver==none) return;
   t = transmsg_receiver.getmessage();
   if(t==none) return;
   msg_raw = t.message;
   if(msg_raw == "") return;
   if(caps(left(msg_raw,7)) == "AERIDM ") return;  // (NOTE THE TRAILSPC) this msg is downloading, ignore until full
   if(transmsg_applied_scroll > 0) msg_raw = right(msg_raw, len(msg_raw) - transmsg_applied_scroll);
   k = len(msg_raw);
   k -= translator_max_rows * translator_max_cols;
   if(k < 0) k = 0;
   transmsg_remain_scroll = k;
   cut_message(msg_raw,translator_max_cols,translator_max_rows,false);
}

function cut_message(string msg_raw,byte max_cols,byte max_rows,bool bSignTarg){
   local byte i;
      if(bSignTarg) for(i=0;i<max_rows;i++) areasign_screendata[i] = "";
       else         for(i=0;i<max_rows;i++) transmsg_screendata[i] = "";
   i = 0;
   while((len(msg_raw) >= 0 ) && i<max_rows){
      if(bSignTarg) areasign_screendata[i] = left(msg_raw,max_cols);
       else         transmsg_screendata[i] = left(msg_raw,max_cols);
      msg_raw = right(msg_raw,len(msg_raw)-max_cols);
      i++;
   }
   if(bSignTarg && len(msg_raw) <= (max_rows/2 * max_cols)){   // auto center vert align
      areasign_screendata[2] = areasign_screendata[1];
      areasign_screendata[1] = areasign_screendata[0];
      areasign_screendata[0] = "";
   }
}

function postrender(canvas c){
   if(canvas_finfo == none) return;
   c.font = canvas_finfo.GetCanvasFont();
   return;
   c.setpos(100,100);
//   debugstr = "hello";
   c.drawtext("Debug: "$debugstr);
}

function report_trans_msg_download(){
   local translatorevent t;
   local int payload_done,payload_done_ind,payload_tot,tmp_pos;
   local float dl_progress;
   local string msg_raw,anim_dl_disp,dl_progress_str,dl_time_unit,dl_ruler;
   local byte i;
   if(!ena_translator) return;
   if(transmsg_receiver == none) return;
   if(level.timeseconds - decline_timer._dlmsg < 0.1) return;
   decline_timer._dlmsg = level.timeseconds;
   t = transmsg_receiver.getmessage();
   if(t == none) return;
   msg_raw = t.message;
   if(msg_raw == "") return;        // progress message not set by trigger
   if(caps(left(msg_raw,7)) != "AERIDM ") return; // (NOTE THE TRAILSPC)
   tmp_pos = instr(msg_raw,";;;");                                            // search for marker
   if(tmp_pos == -1) return;        // progress marker not found
   payload_done = int( mid(msg_raw,7,tmp_pos-7));
   payload_tot  = int(right(msg_raw,len(msg_raw)-tmp_pos-3));
   if(payload_done<0) payload_done = 0;
   if(payload_tot<=0) payload_tot  = 1; // prevent divide by zero
   if(payload_done>payload_tot) payload_tot = payload_done; // prevent more than 1.0000
   // ----------------------------------------------------------------------------------------  progress bar
   dl_progress = float(payload_done);
   dl_progress /= payload_tot;
   dl_progress_str = mid(string(dl_progress),2,2);
   if(dl_progress < 0.1) dl_progress_str = right(dl_progress_str,1); // trunc LZ from 0.07 for 7%, not 07%
   payload_done_ind = dl_progress * 25;
   tmp_pos          = 25 - payload_done_ind;  // safe to use this var
   dl_ruler = "[";    for(i=0;i<payload_done_ind;i++) dl_ruler $= "#";
                      for(i=0;i<tmp_pos;         i++) dl_ruler $= " ";     dl_ruler $= "] ";
   // ----------------------------------------------------------------------------------------  waitsign anim
   anim_dl++;
   if(anim_dl > 3) anim_dl = 0;
   switch(anim_dl){
      case 0: anim_dl_disp = "-";  break;
      case 1: anim_dl_disp = "\\"; break;
      case 2: anim_dl_disp = "|";  break;
      case 3: anim_dl_disp = "/";  break;
   }
   // ----------------------------------------------------------------------------------------
   transmsg_screendata[0] = "SLF preamble found. Recv... "$anim_dl_disp;
   // ----------------------------------------------------------------------------------------
   transmsg_screendata[1] = dl_ruler $ dl_progress_str $ "%";
   transmsg_screendata[2] = "Payload: " $ payload_tot; //  $ " bytes";
   // ----------------------------------------------------------------------------------------  ETA calc
              tmp_pos = 26; dl_progress_str = "2.6"; // minimum
   switch(modem_rssi){
      case 1: tmp_pos = 43; dl_progress_str = "4.3"; break;   // this shitcode is like:
      case 2: tmp_pos = 58; dl_progress_str = "5.8"; break;   // "if I can do without string parse, I do"
      case 3: tmp_pos = 70; dl_progress_str = "7.0"; break;
      case 4: tmp_pos = 79; dl_progress_str = "7.9"; break;   // todo also correct add_done in AerWk_IDM
      case 5: tmp_pos = 88; dl_progress_str = "8.8"; break;
      case 6: tmp_pos = 95; dl_progress_str = "9.5"; break;
   }
//   dl_progress += (FRand() * 0.4 * 2) - 0.4;  // todo monitor scalar owner.velocity here to reduce speed deviations
//   dl_progress_str = string(dl_progress);
/*  byte bint = bps >> 3    // before decimal dot: just int div by 8       // alt calc function for
    byte bflo = bps & 7;                                                   // propagation irradiators
    if(bflo >= 4) flo++;    // after: determine actual decimal fract       // calcd as RMS of dist
                            // output: bint $ "." $ bflo;      */
   dl_progress = float(payload_tot - payload_done);
   dl_progress /= tmp_pos;
   dl_progress *= 10;
   dl_time_unit = " sec";
   if(dl_progress >= 60.0){
      dl_progress /= 60;      // sec to min
      dl_time_unit = " min";
   }
   tmp_pos = int(dl_progress) + 1;
   transmsg_screendata[3] = "Link: " $ dl_progress_str $ " bytes/sec  ETA: " $ tmp_pos $ dl_time_unit;
   transmsg_screendata[4] = "";
   transmsg_screendata[5] = "Superlow frequency speed degrade";
   transmsg_screendata[6] = "while underground or underwater.";
   for(i=7;i<translator_max_rows;i++) transmsg_screendata[i] = "";
   transmsg_applied_scroll = 0;
}

function populate_trans_msg(){     // bug: areasign can be writed in msg history tho shouldnt. ocurrs when ena_translator=1
   local translatorevent t;        // maybe fixed
   local bool transmsg_relevant;
   if(snipe || DisableReader || transmsg_receiver==none) return;
   if(level.timeseconds - decline_timer._showmsg < 0.5) return;
   decline_timer._showmsg = level.timeseconds;
   t = FindTransEvent();
   if(!transmsg_proximity || t==none) return;
   if(t.message == "") return;
   if(instr(caps(t.hint),"AERLOCSIGN") != -1){                           // found location sign, do not store in history
      if(ena_translator || ena_areamap) return;                          // just skip if already using screen
      cut_message(t.message,areasign_max_cols,areasign_max_rows,true);
      trans_msg_areasign = true;
      return;
   }
   transmsg_relevant = (instr(caps(string(t.group)),"AERIGNORE") == -1);
   if(transmsg_relevant) transmsg_receiver.setmessage(t);
   if(transmsg_receiver.bNewMessage && transmsg_relevant){
      tds_oper = 1;
      transmsg_applied_scroll = 0;
      query_trans_msg_data();
      ena_translator = true;
      ena_areamap = false;
      t.group = 'AERIGNORE';
   }
}

/*
function do_visibility(playerpawn p){          // irradiator stalker-like vis calculator, for maybe used as realtime rssi
   local light L;
   local float dist_x,dist_y,dist_z;
   local float LightVisibility,LRadius,LDistance;
   LightVisibility = 0;
   foreach radiusactors(class'light',L,6400){
      if(!p.LineOfSightTo(L))  continue;
      if(L.bSpecialLit)        continue;
      if(L.LightType==LT_None) continue;
      if(L.LightRadius==0)     continue;
      if(L.LightBrightness==0) continue;
      LRadius=(FClamp(L.LightRadius/255.0,0,1)*6400);
      dist_x    = (p.location.x - l.location.x)**2;
      dist_y    = (p.location.y - l.location.y)**2;
      dist_z    = (p.location.z - l.location.z)**2;
      LDistance = (dist_x + dist_y + dist_z)**0.5;
      LRadius  -= LDistance;
      if(LRadius<0.0) LRadius = 0.0;
      LRadius  *= 0.5;
      LDistance = (L.LightBrightness/255.0);
      LightVisibility += (LRadius * LDistance);
   }
   if(Region.Zone.AmbientBrightness>0){ LightVisibility+=Region.Zone.AmbientBrightness/2; }
   else if(pw_sens_crouch) LightVisibility*=0.3;
   glob_LightVisibility = LightVisibility;
}
*/
function query_hide_msg(){
   if(!transmsg_proximity) return;
   if(snipe) goto hide_msg_immediate;
   if(level.timeseconds-decline_timer._hidemsg < HideMsgInterval) return;  // delayed
   if(ena_translator && FindTransEvent()==none) ena_translator = false;
   hide_msg_immediate:
   trans_msg_areasign = false;
   if(transmsg_last_known != none) transmsg_last_known.group = '';
   transmsg_last_known = none;
   transmsg_proximity = false;
}

function do_forcefield_overrange_shdn(){
   local float dist_field_float;
   if(forcefield[0]==none && forcefield[1]==none) return;
   if(pawn(owner)==none || ena_emi){
      query_forcefield(0,0);
      query_forcefield(1,0);
      collapse_shield();
      return;
   }
   if(forcefield[0] != none){                                             // magic numbers meaning:
      dist_field_float = vsize(forcefield[0].location-owner.location)/72; // 0..1280 after consume level apply
      dist_field_float *= forcefield[0].field_consume_level;              // wtf is 72: 1280/72 (maxdist/wtf) should be 17.7777
      if(!boost_power) dist_field_float *= 5;       // 2024-04-27: 5x faster DSR energy loss w/o ext. power
      dist_field[0] = clamp(int(dist_field_float),1,213);                 // wtf is 17.7777: 17.7777*12 (wtf2*maxlevel) s.b. 213
      if(dist_field[0] >= 213) query_forcefield(0,0);                     // 213 is max display pixels.
   }
   if(forcefield[1] != none){                                             // wrote this block twice
      dist_field_float = vsize(forcefield[1].location-owner.location)/72; // because fuck it,
      dist_field_float *= forcefield[1].field_consume_level;              // kludging cycle here is shit
      if(!boost_power) dist_field_float *= 5;
      dist_field[1] = clamp(int(dist_field_float),1,213);
      if(dist_field[1] >= 213) query_forcefield(1,0);
   }
}

function do_opermsg_clr(){
   if(!warn_opermsg) return;
   if(level.timeseconds-decline_timer._unwarnom < 4.0) return;
   aux_oper_msg[0] = "";
   aux_oper_msg[1] = "";
   warn_opermsg = false;
}

function do_auxswitch_errwarn_clr(){
   if(!warn_aux) return;
   if(level.timeseconds-decline_timer._unwarnaux < 0.3) return;
   warn_aux = false;
}

function do_forcefield_span(){
   local triggers fa;
   fa = FindAERTrigger(owner_location, 160, true);
   if(fa != none && fa.isa('aerfieldattractor')){
      sensed_forcefield_attractor = fa;
      decline_timer._unspanff = level.timeseconds;
   }
}

function do_forcefield_unspan(){
   if(sensed_forcefield_attractor == none) return;
   if(level.timeseconds - decline_timer._unspanff < 0.5) return;
   decline_timer._unspanff = level.timeseconds;
   sensed_forcefield_attractor = none;
}

function do_opertrig_forget(){
   if(level.timeseconds - decline_timer._untrig < 0.5) return;
   decline_timer._untrig = level.timeseconds;
   mwheel_trig = 0;
}

function do_dmgmon_write(byte newdata_admg){
// if(low_batt) newdata_admg = 0;                      // 2024-04-13: deleted, now monitors avail even if lowbatt
   if(newdata_admg == 40 || newdata_admg == 50){
      penetrability_monitor[penmon_capacity]._admg = newdata_admg; return;
   }
   if(newdata_admg > penetrability_monitor[penmon_capacity]._admg)
      penetrability_monitor[penmon_capacity]._admg = clamp(newdata_admg,0,25);
}

function do_penmon_write(byte newdata_pen, byte newdata_full){
//2024-04-17: deleted move routines from write func. maybe graph will be more smooth
//   local byte i;
//        decline_timer._clrpenmon = level.timeseconds;       // not so necessary but graph look better
//        for(i=1;i<penmon_capacity;i++) penetrability_monitor[i-1] = penetrability_monitor[i];
     /* if(low_batt){                                       // 2024-04-13: deleted
           newdata_pen = 0;
           newdata_full = 0;
        }  */
// 2024-12-08: enough test, no animtearing, all above former code may be deleted
        penetrability_monitor[penmon_capacity]._rem  = clamp(newdata_pen, 0,25);
        penetrability_monitor[penmon_capacity]._full = clamp(newdata_full,0,25);
//        decline_timer._clrpenmon = level.timeseconds; // may be deleted
}

function do_penmon_clr(){
   local byte i;
   if(level.timeseconds - decline_timer._clrpenmon < BaseScrollInterval) return;
   decline_timer._clrpenmon = level.timeseconds;
   for(i=1;i<penmon_capacity;i++) penetrability_monitor[i-1] = penetrability_monitor[i];
   penetrability_monitor[penmon_capacity]._rem = 0;
   penetrability_monitor[penmon_capacity]._full = 0;
   penetrability_monitor[penmon_capacity]._admg = 0;
}

function Timer(){
// local actor atarg;
   local float bestAim; //, bestDist;  
   local playerpawn p;
// local pawn targ;
// local byte pt;
   p = playerpawn(owner);
   // -------------------- this ensure correct thrown weapon behavior -------------------
   if(p == None){
      GotoState('Pickup');
      if(ambientsound != none) ambientsound = none;    // todo delete all synth
      return;
   }
   if(!isinstate('Idle')) GotoState('Idle');
   if(ammotype != none){
      if(ammotype.ammoamount < pickupammocount) ammotype.ammoamount = pickupammocount;
   }
   // -----------------------------------------------------------------------------------
   do_leash_laser();
   do_hitsens_set();
   do_hitsens_clr();
   do_penmon_clr();
   do_reammo();
   populate_trans_msg();
   report_trans_msg_download();
   query_hide_msg();
   do_forcefield_overrange_shdn();
   do_opermsg_clr();
   do_auxswitch_errwarn_clr();
   do_forcefield_span();
   do_forcefield_unspan();
   do_opertrig_forget();
   do_external_managers_poll();
   if(radar_vqty>0){
      decline_timer._unsnipe = level.timeseconds;
      snipe = true;
      do_shutdown_translator();
      do_shutdown_areamap();
   }
   aercfg_advance_hello();
   if(snipe && radar_vqty<=0 && level.timeseconds-decline_timer._unsnipe >= 1.2) snipe=false;
   if(p.weapon != self) return;
// pt = p.playerreplicationinfo.team + 1;   // from H.E.R code
   bestaim = 0.95;
/* atarg = p.picktarget(bestaim, bestDist, vector(p.viewrotation), p.location);
   targ = pawn(atarg);
   if(targ != none) attempt_tag_target(targ);  */  // 2024-12-03: disabled picktarget to prevent non-lased ATT
   if(!ena_emi && ambientsound == none &&   ava_synth && synth_chg>=synth_max) ambientsound = sound'aermshum';
   if(ena_emi || (ambientsound != none && (!ava_synth || ammo_chg>=ammo_max))) ambientsound = none;
   settimer(0.05, true);
}

function do_tick_carry_laser(){
   local vector HitLoc, HitLocSec, HitNor, EndTrace, x, y, z;
   local rotator r;
   local float lasermult, laserdist;
   local vector laserorigin;
   local actor atarg_pri,atarg_sec;
   local pawn ptarg;
   local bool targ_is_ffield,
              targ_is_hdm,
              targ_is_thdm;
   local bool laser_hide_pri,
              laser_sky_pri, laser_sky_sec;
   local bool tmp_surelock;
   laserorigin = owner_location;
   if(lightbeam != none && lightbeam.LightType == LT_Steady){
      r = owner_viewrotation;
//    r.pitch = r.pitch % 65536;
//    r.pitch = 0;
//    r.pitch = clamp(r.pitch,-4096,8192);
//    getaxes(r,x,y,z);
//    lightbeam.setlocation(laserorigin + z*4 + x*40);
      lightbeam.setlocation(laserorigin);
      r.pitch -= 6144; // was 8192
      lightbeam.setrotation(r);
   }
   getaxes(owner_viewrotation,x,y,z);
   if(shield_blk != none) laserorigin += x*390;  // 320+128 shield, must be more
   laserorigin += z*2;     // maybe todo crouching handling
   laserorigin += y*4;
   EndTrace = laserorigin + 15000 * x;            // on no06heiko laser go crazy, can't use hitloc for aim calcs
   atarg_pri = Trace(HitLoc,HitNor,EndTrace,laserorigin,True);
   atarg_sec = Trace(HitLocSec,HitNor,EndTrace,Hitloc + x*128,True);
   targ_is_ffield = bool(aerffieldblk(atarg_pri));
   targ_is_hdm =  (instr(caps(string(atarg_pri.group)),"AERBLOCK")  != -1);
   targ_is_thdm = (instr(caps(string(atarg_pri.group)),"AERTBLOCK") != -1);
   hdmlock = targ_is_hdm && ena_laser;
   tmp_surelock = false;
   ptarg = pawn(atarg_pri);
   if(ptarg != none){
      if(instr(caps(string(ptarg.group)),"AERTARG") != -1) tmp_surelock = true;
      if(ena_laser) attempt_tag_target(ptarg); // 2024-04-28: only tag by laser, returned 2024-12-05
      // todo override if(ena_laser) for small nastypawns (make isA func for them)
   }
   ptarg = pawn(atarg_sec);
   if(ptarg != none){
      if(instr(caps(string(ptarg.group)),"AERTARG") != -1) tmp_surelock = true;
      if(ena_laser && !targ_is_hdm && !targ_is_thdm) attempt_tag_target(ptarg); // 2025-01-07: only first laser tags, only thru non-HDM
   }
   if(!ena_laser) tmp_surelock = false;
   surelock = tmp_surelock;          // minimize time amount while this being changed
   hitloc -= x*7;
   hitlocsec -= x*7;
   laserdist = vsize(owner_location - hitloc);
   range = laserdist;
   if(targ_is_ffield) range = vsize(owner_location - hitlocsec);
   if(!ena_laser) return;
   if(laserdot == none || laserdotsec == none) return;
   laserdot.setlocation(hitloc);
   laserdot.range = range;             // 2024-07-27: makenoise moved into laser
   laserdot.bearing = owner_viewrotation.yaw;
// if(range < 1880 && ptarg != none) laserdot.makenoise(1.0);  // aggro pawns on first laser closer than 40m, 2024-04-14: deleted
   TraceSurfHitInfo(HitLoc,HitLoc + x*15,,,,LaserFlags);
   laser_hide_pri = false;
   if((LaserFlags & PF_Invisible)!=0 || (LaserFlags & PF_Semisolid)!=0) laser_hide_pri = true;
   if((LaserFlags & PF_Masked)!=0 || (LaserFlags & PF_Translucent)!=0 || (LaserFlags & PF_Modulated)!=0) laser_hide_pri = true;
   laserdotsec.setlocation(hitlocsec);
   laserdotsec.range = range;
   laserdotsec.bearing = owner_viewrotation.yaw;
   laser_sky_pri = (LaserFlags & PF_FakeBackdrop)!=0;
   TraceSurfHitInfo(HitLocSec,HitLocSec + x*15,,,,LaserFlags);
   laser_sky_sec = (LaserFlags & PF_FakeBackdrop)!=0;
   inhibit_laser = laser_sky_pri || laser_sky_sec;
   if(inhibit_laser) goto skip_independent_distractor;
   if(atarg_pri.isa('aerlaserdistractor')) inhibit_laser = true;
   if(instr(caps(string(atarg_pri.group)),"AERLASERDISTRACTOR") != -1) inhibit_laser = true;
   skip_independent_distractor:
   LaserDot.bHidden = laserdist<96 || targ_is_ffield || inhibit_laser;
   lasermult=fclamp(laserdist/2800,-0.3,1.3);
   lasermult+=1;
   if(laserdist>2800) lasermult+=1;
   if(laserdist>5600) lasermult+=1;
   LaserDot.drawscale=lasermult;
//   LaserDot.LightBrightness=clamp(int(lasermult*25),15,255);
//   if(LaserDot.LightType!=LT_Steady) LaserDot.LightType=LT_Steady;
   laserdist=vsize(owner_location-hitlocsec);
   laserdotsec.bhidden = laserdist<96 || ena_setup || targ_is_hdm || targ_is_thdm || inhibit_laser;
   lasermult=fclamp(laserdist/2800,-0.3,1.3);
   lasermult+=1;
   if(laserdist>2800) lasermult+=1;
   if(laserdist>5600) lasermult+=1;          // fix calibration of this shit, poor laser visibility on cancer videocards
   laserdotsec.drawscale=lasermult;
/*   if(laserdotsec.bhidden){
      laserdotsec.LightBrightness=0;
      laserdotsec.LightType=LT_None;
   }else{
      laserdotsec.LightBrightness=clamp(int(lasermult*25),15,255);          // 2025-04-27: added secondary laser ambilight
      laserdotsec.LightType=LT_Steady;
   } */
   do_carry_particle_lasers();
}

function do_carry_particle_lasers(){

}

function do_leash_laser(){
   if(!ena_laser) return;
   if(level.timeseconds - decline_timer._releash <= 2.0) return;
   decline_timer._releash = level.timeseconds;
   if(laserdot == none || laserdotsec == none){  // laser isn't exist while must be
      query_laser(false,false);                  // ctrl alt del this fucker
      if(ava_laser) query_laser(true,false);
      return;
   }
   if(laserdot.physics == PHYS_None && laserdotsec.physics == PHYS_None) return;
   laserdot.setPhysics(PHYS_None);               // workaround unwanted zonevelocity inheritance
   laserdot.velocity = vect(0,0,0);
   laserdotsec.setPhysics(PHYS_None);
   laserdotsec.velocity = vect(0,0,0);
}

function do_tick_query_fire(bool no_p_fire,bool no_p_altfire){
   if(no_p_altfire) pw_sens_altfire = false;    // for shield commands
   if(no_p_fire){
      pw_sens_fire=false;
//    if(fired) owner.playsound(sound'aerfire_reload', SLOT_None, 32); // 2025-06-29: cringy, reload snd needed
                                                                       // after each fire, not last one
      fired = false;
      return;
   }
   if(fired && !ena_fullauto) return;                // variant 1, contolled by ena_fullauto
// if(fired && (ena_emi || !ena_fullauto)) return;   // variant 2, EMI cause semiauto
   fire(0.0);
}

function do_tick_altfire_set(playerpawn p){          // bug: rmouse slows down charge while translator, tho shouldnt
   local rotator r;
   local int priorange;
   if(p.weapon != self) return;
   if(entering_setup || ena_setup) return;
   if(!pw_sens_altfire || bMyOwnsCrosshair) return;
   bMyOwnsCrosshair = true;
   r = owner_viewrotation;
   aux_old_yaw = r.yaw;
   decline_timer._reclick=level.timeseconds;
   if(ena_fast_shield) return;
   zoomfactor = 1;
   priorange = anylock ? range_targ : range;
   if(priorange > 520)  zoomfactor=2;
   if(priorange > 690)  zoomfactor=3;
   if(priorange > 1130) zoomfactor=4;
   if(priorange > 1673) zoomfactor=5;
   if(priorange > 2400) zoomfactor=6;
   if(priorange > 3700) zoomfactor=7;
   if(priorange > 5446) zoomfactor=8;
   if(priorange > 7733) zoomfactor=9;
   newFOV = fclamp(UserSetFOV/zoomfactor, 8.0, UserSetFOV);     // was 12.5
   p.mousesensitivity = initial_mousesens/(UserSetFOV/newfov);
}

function do_tick_shield_capacitor(){
   if(level.timeseconds - decline_timer._sh_cap < 0.040) return;
   decline_timer._sh_cap = level.timeseconds;
   if(!pw_sens_altfire && fast_shield_chg<275 && batt_chg>0
       && state_forcefield[0]!=1 && state_forcefield[1]!=1){  // 2025-04-24: any of F1 F2 fields prevents capactor charge
      consume_main_cell(batt_per_shield);
      fast_shield_chg++;
   }
   if(transmsg_proximity) return;
   if(!ena_fast_shield || !pw_sens_altfire || ena_translator || ena_areamap) return;
   if(fast_shield_chg >= 4){  do_shield_degrade(4); return;  }  // was max eat 5, shit
   if(fast_shield_chg >= 3){  do_shield_degrade(3); return;  }
   if(fast_shield_chg >= 2){  do_shield_degrade(2); return;  }
   if(fast_shield_chg == 1){  do_shield_degrade(1); return;  }
}

function do_shield_degrade(byte incoming_dmg){
   local byte shield_dmg_tmp;
   local int pop_add_tmp;
   shield_dmg_tmp = clamp(incoming_dmg,0,fast_shield_chg);
   fast_shield_chg -= shield_dmg_tmp;
   pop_add_tmp = populated_shield_dmg + shield_dmg_tmp;
   if(pop_add_tmp < 255) populated_shield_dmg += shield_dmg_tmp;
    else populated_shield_dmg = 255;
   if(fast_shield_chg == 0) collapse_shield();
}

function do_shield_dmg_decay(){
   if(level.timeseconds - decline_timer._sh_dmgdec <= 0.02) return;
   if(populated_shield_dmg == 0) return;
   populated_shield_dmg--;
   if(populated_shield_dmg >   2) populated_shield_dmg--;
   if(populated_shield_dmg >   4) populated_shield_dmg--;
   if(populated_shield_dmg >   8) populated_shield_dmg--;
   if(populated_shield_dmg >  16) populated_shield_dmg--;
   if(populated_shield_dmg >  32) populated_shield_dmg--;
// if(populated_shield_dmg >  64) populated_shield_dmg--;  // unused
// if(populated_shield_dmg > 128) populated_shield_dmg--;
   decline_timer._sh_dmgdec = level.timeseconds;
}

function do_tick_shield(){
   local rotator pawnrot;
   local vector x,y,z,field_origin;
   local pawn t;
   local bool tmp_snipe;
   if(pawn(owner)==none || ena_emi) return;
   do_tick_shield_capacitor();
   do_shield_dmg_decay();
   if(!ena_fast_shield) return;
   if(ena_areamap) return;       // 2025-11-29
   tmp_snipe = false;
   if(snipe) tmp_snipe = true;   // shield won't activate if altfire pressed to pause message reader
                                 // upd: unused since messagereader marquee removed. this code should be left intact
   foreach RadiusActors(class'pawn', t, RadarScanRadius>>2) if(t.AttitudeToPlayer<ATTITUDE_IGNORE) tmp_snipe = true;
   if((ena_translator || ena_areamap) && !tmp_snipe) return;   // no treat present, shield can be paused
   pawnrot = owner_viewrotation;
   getaxes(pawnrot,x,y,z);
   field_origin = owner_location + 320.0*x;
   if(pw_sens_altfire && fast_shield_chg > 1) goto deploy_shield;     // suff chg and altfiring
   collapse_shield();                                                 // all other cases = collapse
   return;
   deploy_shield:
   if(shield_blk == none){
      shield_blk = Spawn(class'AerWk_FSS', Owner, '', field_origin, pawnrot);
      shield_blk.w = self;
   }else{
      shield_blk.setlocation(field_origin);
      shield_blk.setrotation(pawnrot);
      shield_blk.lifespan=1.4;
   }
}

function collapse_shield(){
   if(shield_blk == none) return;
   shield_blk.destroy();
   shield_blk = none;
}

function do_tick_altfire_clr(playerpawn p){
   local rotator r;
   local float aux_new_yaw;
   local float clickspeed;
   local bool aux_imminent,aux_exec,aux_exec_alt,aux_inc,aux_dec;
   if(entering_setup || ena_setup) return;
   if(pw_sens_altfire || !bMyOwnsCrosshair) return;
   bOwnsCrosshair = true;
   bMyOwnsCrosshair = false;
   clickspeed = level.timeseconds - decline_timer._reclick;
   newfov = initial_fov;
   p.mousesensitivity = initial_mousesens;
   zoomfactor = 1;
   r = p.ViewRotation;
   aux_new_yaw = r.yaw;
   aux_exec     = clickspeed <  RClickExecCmdMax;
   aux_imminent = clickspeed >= RClickChgModeMin    && clickspeed < RClickChgModeMax;
   aux_exec_alt = clickspeed >= RClickExecAltCmdMin && clickspeed < RClickExecAltCmdMax;
   aux_inc      = aux_new_yaw > aux_old_yaw;
   aux_dec      = aux_new_yaw < aux_old_yaw;
              goto skip_mandatory_crouch;   // 2024-11-15: anyway skip. impacts UX while battle, this is shit
   if(!snipe) goto skip_mandatory_crouch;
   if(aux_imminent && !pw_sens_crouch){
      decline_timer._unwarnaux = level.timeseconds;
      warn_aux = true;
      aux_imminent = false;
   }
   skip_mandatory_crouch:
   if(aux_imminent && aux_inc){                     // aux_oper bounds check begin
      if(ena_translator){ tds_oper = (tds_oper==0) ? 1 : 0; return; }   // safe to exit here, all done
      if(aux_oper<4) aux_oper++; else aux_oper=1;
      aux_validate(true);
   }
   if(aux_imminent && aux_dec){                     // aux_inc and aux_dec cmds was 0..4, changed to 1..4
      if(ena_translator){ tds_oper = (tds_oper==0) ? 1 : 0; return; }
      if(aux_oper>1) aux_oper--; else aux_oper=4;   // due to LP is moved to MWheelClick and
      aux_validate(false);                          // first mode (aux_oper=0) is now unselectable
   }                                                // aux_oper bounds check ends
   if(aux_exec){
//    if(aux_oper==0) aertogglelaser();             // 2024-08-20: disabled
      if(aux_oper>=1 || aux_oper<=3) aux_oper=4;    // other modes toggle: moved to AERScrollProcess()
      if(aux_oper==4) query_push(p.Location,r);
   }
// if(aux_exec_alt){                                // unused, alt actions for long rclick
// }
}

function aux_validate(bool dir_r){
   if(!dir_r) goto dir_l;
   if(aux_oper==0) /* 2024-08-21: always skipped */         aux_oper++;
// if(aux_oper==0 && !ava_laser)                            aux_oper++;
   if(aux_oper==1 && !ava_ffield && state_forcefield[0]==0) aux_oper++;
   if(aux_oper==2 && !ava_ffield && state_forcefield[1]==0) aux_oper++;
   if(aux_oper==3 && !ava_invis)                            aux_oper = 4;
   return;
   dir_l:
   if(aux_oper==3 && !ava_invis)                            aux_oper--;
   if(aux_oper==2 && !ava_ffield && state_forcefield[1]==0) aux_oper--;
   if(aux_oper==1 && !ava_ffield && state_forcefield[0]==0) aux_oper--;
   if(aux_oper==0) /* 2024-08-21: always skipped */         aux_oper = 4;
// if(aux_oper==0 && !ava_laser)                            aux_oper = 4;
}

function do_external_managers_poll(){
        local triggers extmgr;
        local AerAm_shard as;
        local bool any_shards;  // todo qty shards score, only synth if 5 reached. water modifier: +2, crystals +3 or more (cfgable)
                                // todo or affect speed
        local bool mgr_synth,mgr_power,mgr_feature;
        if(!boost_power && ena_powercell) boost_power = true;
        if(level.timeseconds - decline_timer._refeature < 0.5) return;
        decline_timer._refeature = level.timeseconds;
        any_shards = false;
        foreach radiusactors(class'aeram_shard',as,128,owner_location) any_shards = true;
        extmgr = FindAERTrigger(owner_location, 128, false);
        mgr_synth   = false;
        mgr_power   = false;
        mgr_feature = false;
        if(extmgr!=none){
           if(extmgr.isa('aersynthaccelerator')) mgr_synth   = true;
           if(extmgr.isa('aerpoweraccelerator')) mgr_power   = true;
           if(extmgr.isa('aerfeaturemanager'))   mgr_feature = true;
        }
        if(mgr_feature){
           extmgr.setcollision(false,false,false);  // bTriggerOnceOnly mimic
                  // todo commands
//         broadcastmessage("Found AFM, cmd: "$extmgr.group);
        }
        ava_synth = ena_synth && (mgr_synth || any_shards); // || p.region.zone.bWaterZone);  p is inacessible now. //todo mb delete
        if(!ava_synth && synth_chg>0) synth_chg = 0;
        boost_power = mgr_power || ena_powercell;
}

function query_push(vector l, rotator r){
   local aerprjpushmove pm;
// local aerprjpushdeco pd;
   local vector x, y, z;
   do_shutdown_translator();
   do_shutdown_areamap();
   if(!ena_fast_shield) ena_fast_shield = true;
   if(level.timeseconds - decline_timer._repush < PushInterval) return;
   query_invis(false);
   getaxes(r,x,y,z);
   decline_timer._repush = level.timeseconds;
   owner.playsound(sound'aerpush', SLOT_None, 16);
//      spawn(class'aerprjpushdeco',,,l+12*z+1*y,r);  //2024-12-21: removed airpush trails
// pd = spawn(class'aerprjpushdeco',,,l+12*z+1*y,r);
   pm = spawn(class'aerprjpushmove',,,l+12*z+1*y,r);
   if(DisablePushCorridorBalance && pm != none) pm.DisablePushCorridorBalance=true;
}

function do_reammo(){
   local float synth_1divx_speed;
   if(synth_chg<synth_max || ena_emi) return;
   synth_1divx_speed = 4;
   if(ammo_chg > 10) synth_1divx_speed = 3;
   if(ammo_chg > 20) synth_1divx_speed = 2;
   if(ammo_chg > 30) synth_1divx_speed = 1;
   if(!ava_synth) return;
   if(level.timeseconds - decline_timer._reammo < 0.8 * synth_1divx_speed) return;
   if(ammo_chg<ammo_max) ammo_chg++;
   decline_timer._reammo = level.timeseconds;
}

function do_tick_aim(){
   local byte aim_restore_speed;
   if(deaim_rate<=default.deaim_rate) return;
   aim_restore_speed = clamp(deaim_rate,1,6);
   if(pw_sens_crouch && aim_restore_speed>=2) aim_restore_speed = aim_restore_speed>>1;
   if(level.timeseconds-decline_timer._refire>BaseFireInterval*4) aim_restore_speed = 1;
   if(level.timeseconds-decline_timer._reaim<=BaseFireInterval*aim_restore_speed) return;
   decline_timer._reaim = level.timeseconds;
   deaim_rate--;
}

function do_tick_power(float known_batt_deficit){
   local float more_decline, tmp_slowdown;
   local int power_reqr_tmp;
   local bool repower_while_fire;
// ------------------------------------------------------------------------------------------------- // cancer var usage
   more_decline = known_batt_deficit - 0.74;      // was 42% = degrade start (0.58 = 1.00 - 0.42)
   if(more_decline < 0.0) more_decline = 0.0;     // 0%  = degrade end
   more_decline *= 3.846153;                      // scale to full float (0.42 * 2.380953 = 1.00000)
   power_reqr_tmp = power_max_top;                // set max extra
   power_reqr_tmp -= power_max_bot;
   power_reqr_tmp -= int(more_decline * (power_max_top-power_max_bot));  // lower deficit = higher extra chg
// if(ena_emi) power_reqr_tmp = 0;   // 2025-01-01 bal-chg: while EMI, only minimum power working // 2025-01-08: WTF? it shielded
   power_max = power_max_bot + power_reqr_tmp;          // apply extra power
   if(power_max < power_chg) power_max = power_chg;     // protect from invisible charged bars
// ------------------------------------------------------------------------------------------------- // cancer usage ends
   more_decline = 0.0;
   tmp_slowdown = cap_process_slowdown;
// if(ena_emi){}             // balance change: deleted. EMI can't affect internal AER circuits, only LCD
// if(power_chg <= 7) more_decline += 0.05; // 50-200ms addtax          2024-10-06: removed
// if(power_chg <= 4) more_decline += 0.1; 
// if(power_chg <= 2) more_decline += 0.2;
   if(ena_fast_shield && pw_sens_altfire) more_decline += (BaseRepowerInterval*0.7); // todo mb ena_trans checks here
   more_decline *= tmp_slowdown;
   if(low_batt) more_decline += 1.1;
   if(power_chg>=power_max)  more_decline += 0.8;  // synth chg slow
   if(boost_power) more_decline *= 0.33;           // was /=3
   if(level.timeseconds - decline_timer._repower <= BaseRepowerInterval * tmp_slowdown) return;
   power_reqr_tmp = power_max;
   if(low_repower) power_reqr_tmp = ammo_chg;
   repower_while_fire = !pw_sens_fire;                  // 24-10-17: balance change, trigger hold doesn't prohibit repower
   if(power_chg<=0) repower_while_fire = true;  // ???  // kept prohibiting while nonzero ammo, for less display noise
   if(power_chg<power_reqr_tmp && repower_while_fire){
      consume_main_cell_heavy(batt_per_powercap);
      power_chg++;
      if(pw_sens_altfire && fast_shield_chg > 0){
         do_shield_degrade(1);
         consume_main_cell_heavy(batt_per_powercap_fast);
      }
   }
   if(power_chg>=power_max && synth_chg<synth_max && ammo_chg<ammo_max && ava_synth && !low_batt){  // todo delete all synth
      // consume_main_cell_heavy(210); // was 28        // 24-02-20: do not eat battery for synth
      synth_chg++;
   }
   decline_timer._repower = level.timeseconds + more_decline;
}

function apscan_fillscreen(){
   local vector HitLoc, HitNor, StartTrace, EndTrace;
   local rotator scandir;
   local float sector,vsector,dist,x;
   local byte i;
   local float agc_error;
   local actor a;
   screenbuffer[scanline]=screendata;
   scanline++;
   if(scanline>=apscan_horzres) scanline=0;
   scandir=owner_viewrotation;
   StartTrace = owner_location;
   EndTrace = StartTrace + 15000 * Vector(scandir);
   Trace(HitLoc,HitNor,EndTrace,StartTrace,True);
   dist=vsize(StartTrace-HitLoc);
   savedist=dist;
   sector=65536;
   vsector=49152; // 34380; // was 65536;   // div this hres/vres
   sector/=(360/newfov);              // newfov90=16384, newfov45=8192 etc
   vsector/=(360/newfov);
   scandir.yaw-=sector>>1; //  /2;
   scandir.pitch-=vsector>>1;
   scandir.yaw+=sector/apscan_horzres*(scanline+1);             // iter x
   for(i=0;i<apscan_vertres;i++){
      scandir.pitch+=(vsector/apscan_vertres);                  // iter y
// these randoms destroying picture strong enough, good for radiation
      if( true                                              && FRand() <= 0.1) continue;
      if(level.timeseconds - decline_timer._initscan <= 3.0 && FRand() <= 0.2) continue;
      if(level.timeseconds - decline_timer._initscan <= 5.0 && FRand() <= 0.3) continue;
      if(level.timeseconds - decline_timer._initscan <= 7.0 && FRand() <= 0.4) continue;
      if(level.timeseconds - decline_timer._initscan <= 9.0 && FRand() <= 0.5) continue;
      if(level.timeseconds - decline_timer._initscan <= 12.0 && FRand() <= 0.6) continue;
//    if(level.timeseconds - decline_timer._initscan <= 20.0 && FRand() >= 0.5){ screendata.data[i] = rand(255); continue; }
      EndTrace = StartTrace + 15000 * Vector(scandir);
      a=Trace(HitLoc,HitNor,EndTrace,StartTrace,True);
      dist=vsize(StartTrace-HitLoc);
      x=fclamp(dist/maxdist,0.0,1.0);
      screendata.data[i]=255-clamp(x*256,0,255);
   }
   if(scanline==0){
      agc_error=dist-maxdist;
      if(agc_error<0) agc_error*= -1;
      if(savedist<(maxdist/1.6)) maxdist-=agc_error/5.5; else maxdist+=agc_error/5.5;
      if(maxdist<200) maxdist=200;
      if(maxdist>15000) maxdist=15000;
   }
}

function do_apscan_clr(){
   local byte i,j;
   for(i=0;i<apscan_horzres;i++) for(j=0;j<apscan_vertres;j++) screenbuffer[i].data[j]=0;
}

function do_tick_initscan(){
   if(ena_fast_shield || ena_apscan) return;
   if(level.timeseconds - decline_timer._initscan < 0.7) return;
   ena_apscan = true;
   // decline_timer._unwarnom = level.timeseconds - 4.1; // was disabling long snipermode notify. todo remove apscan-related
}

function tick(float f){
   local playerpawn p;
   local pawn pt;
   local float batt_deficit;
   p = playerpawn(Owner);
   if(p == none) return;
   owner_location = p.location;
   owner_viewrotation = p.viewrotation;
   ena_render_scope = (p.weapon == self);
   if(!ena_render_scope) return;
   pw_sens_crouch = p.bIsCrouching;
   do_tick_scan_rssi();
   if(!ena_invis) goto skip_invis;
   for(pt=level.pawnlist; pt!=none; pt=pt.nextpawn) if(pt.enemy == p) pt.enemy = none;  // todo slowdown it by fadetime 0.6
   skip_invis:
   if(p.weapon == self){
      do_tick_carry_laser();
      do_tick_query_fire(p.bFire==0, p.bAltFire==0);
//    if(surelock) do_tick_query_fire(false, p.bAltFire==0); // todo and check autofire
      do_tick_altfire_set(p);
   }
// if(aux_oper==1 || aux_oper==2) goto skip_shield;     // 2024-08-20: now always executed
   do_tick_shield();
// skip_shield:
   if(p.weapon == self) do_tick_altfire_clr(p);
   do_objective_set();
   do_objective_clr();
   processtargets(p);
   processprojectiles(p);
   batt_deficit = batt_full - batt_chg;
   batt_deficit /= batt_full;
   cap_process_slowdown = (batt_deficit * 4.4) + 1.2;  // was 2.8+1.2
   do_tick_power(batt_deficit);
   do_tick_aim();
   if(level.timeseconds - decline_timer._redisch >= 0.1){
      decline_timer._redisch = level.timeseconds;
      if(ena_invis)              consume_main_cell_heavy(4);
      if(state_forcefield[0]==1) consume_main_cell_heavy(forcefield[0].field_consume_level * 10 * clamp(dist_field[0]/71,1,3)); //was 40
      if(state_forcefield[1]==1) consume_main_cell_heavy(forcefield[1].field_consume_level * 10 * clamp(dist_field[1]/71,1,3));
      if(boost_power)            charge_main_cell(320);  // was 650    // avg max discharge was 222
      charge_main_cell(1);
      // todo more charge
   }
   ava_laser    =  batt_chg >= batt_min_one;
// ena_fullauto =  batt_chg >= batt_full/50; /* 2%, renamed to batt_min_five*/  // 2024-08-20: always fullauto
   ava_invis    = (batt_chg >= batt_min_four) && ena_cloak;  // 4%
   ava_fullscan =  batt_chg >= batt_min_four;                // 4%
   ava_ffield   =  batt_chg >= batt_min_five;                // 5%
   low_batt     =  batt_chg < 100;
   low_repower  = (batt_chg < ((power_max - power_chg + 4) * batt_per_powercap)) && ammo_chg<power_max;
// ena_fast_shield = (!pw_sens_crouch && aux_oper!=1 && aux_oper!=2);  // 2024-08-20: autocontrol disabled, now is selectable
   if(!ena_fast_shield && (state_forcefield[0]==1 || state_forcefield[1]==1)) collapse_shield();
   batt_deficit = level.timeseconds - last_firetime;  // this var usage is cancer but ok
   batt_deficit = batt_deficit / BaseFireInterval;
   if(batt_deficit > 255.0) batt_deficit = 255.0;
   fire_idle_chg = byte(batt_deficit);
   if(!ava_laser){
      query_laser(false,true);
      if(lightbeam != none) lightbeam.LightType = LT_None;
   }
   if(!ava_laser && state_forcefield[0]==1) query_forcefield(0,0);
   if(!ava_laser && state_forcefield[1]==1) query_forcefield(1,0);
   if(!ava_invis) query_invis(false);
   if((!ava_laser || !ava_ffield || !ava_invis) && aux_oper != 4) aux_validate(true);
   if(true) apscan_fillscreen();
   do_tick_initscan();
   if(level.timeseconds - decline_timer._redodge <= 0.2) return; // protected by power reqr but necessary anyway, to limit repeatrate
   forced = true;
   p.waterspeed = 200;
}

state Idle{
   function bool ClientAltFire(float f){ return false; }
   function bool ClientFire(float f){
      local byte i;
//    local byte tmp_byte;                             // 2024-04-15: maybe play special sound every x shots
//    pawn(Owner).PlayRecoil(1);                       // NFI purpose of this. old code
      if(!entering_setup && ena_setup) return true;
      if(owner == none) return true;
      owner.playsound(sound'aerfire_reload', SLOT_None, 32);
      for(i=0;i<3;i++){
         if(FirePlayers[i]!=none) FirePlayers[i].query_fire();
      }
/*    tmp_byte = ammo_chg >> 2;                        // 2024-04-15
      tmp_byte = tmp_byte << 2;
      if(ammo_chg == tmp_byte) owner.playsound(sound'aerfire4x', SLOT_Misc, 16); */
      return true;
   }
   function AltFire(float f){ pw_sens_altfire = true; }
   function Fire(float f){
      local vector x, y, z,fireorigin;
      local rotator r;
      local aerprjhurtdmg h;
      local pawn p;
      local float firefactor;
      firefactor = BaseFireInterval;
      if(!entering_setup && ena_setup) firefactor = BIOSFireInterval;
      pw_sens_fire = true;
      p = pawn(owner);             // do not move this lower
      if(p == none) return;
      if(ena_fast_shield && pw_sens_altfire) return;  // prohibit fire while shielding
      do_shutdown_translator();
      do_shutdown_areamap();
      fired = true;
      if(level.timeseconds - decline_timer._refire < firefactor) return;
      if(ammo_chg<=0) return;
      if(power_chg<=0) return;
      if(!ena_setup && !entering_setup){
         if(!InfiniteAmmo) ammo_chg--;
         power_chg--;
      }
      synth_chg = 0;
      if(fire_idle_chg < 40) query_invis(false);     // break invis if fired more often than firerate/40
      ambientsound = none;
      r = p.ViewRotation;
      getaxes(r,x,y,z);
      fireorigin = p.location;
//    fireorigin.z += 15;
      fireorigin += z*2;
      fireorigin += y*4;
      r = rotator(p.location + x*15000 - fireorigin);
      h = spawn(class'aerprjhurtdmg' ,,,fireorigin,r);
      clientfire(f);
      decline_timer._refire = level.timeseconds;
      if(h == none) return;
      h.w = self; // backward radiolink
      if(level.timeseconds - last_firetime >= 0.5) h.higher_ionize = true;
      h.do_ionize();
      last_firetime = level.timeseconds;
      h.target_spot = p.location + x*15000;
      h.deaim_rate = deaim_rate;
      if(deaim_rate<deaim_max) deaim_rate++;
      decline_timer._reaim = level.timeseconds;
      h.penetrability = clamp(range/128,1,25);  // was range/128
      h.maxpenetrability = h.penetrability;
      h.group = 'AERmuzzleproj';          // only weaponborne projectiles have this, chainspawned are not
      h.fire_location = fireorigin;
      if(power_chg > 0) h.fire_power = power_chg;
      if(DisableHitsens) h.DisableHitsens = true;
      h.gotostate('Launch');
   }
   function BeginState(){
//    bPointing = false;               // no fucking idea what's this thing for. this were in Stinger code.
      SetTimer(1.0, false);
      Super.BeginState();
   }
   function EndState(){
      SetTimer(1.0, false);
      Super.EndState();
//    query_laser(false,true);
      query_invis(false);              // disabling this is cancer, we must shut it down when downweapon
   }
Begin:
// bPointing = False;
   finishanim();
   //finish();
   gotostate('idle');
   sleep(0.5);
   if(AmmoType == None){
      GiveAmmo(Pawn(Owner));
      AmmoType.AmmoAmount = PickupAmmoCount;
   }
   Disable('AnimEnd');
   if(Pawn(Owner).bFire != 0 && pawn(owner).weapon == self) fire(0);
}

function PlayIdleAnim(){}
function tweentostill(){}

simulated function assign_spawn_notify(name msg_type){
   local spawnnotify asn;
   local int asn_qty;
   asn_qty = 0;
   foreach allactors(class'spawnnotify',asn){
      if(msg_type == 'blood'  &&  asn.isa('AerSN_blood'))   asn_qty++;
      if(msg_type == 'trail'  &&  asn.isa('AerSN_trail'))   asn_qty++;
      if(msg_type == 'corpse' &&  asn.isa('AerSN_corpse'))  asn_qty++;
      if(msg_type == 'skproj' &&  asn.isa('AerSN_skjproj')) asn_qty++;
   }
   if(asn_qty > 0) return;
      if(msg_type == 'blood')  spawn(class'AerSN_blood');
      if(msg_type == 'trail')  spawn(class'AerSN_trail');
      if(msg_type == 'corpse') spawn(class'AerSN_corpse');
      if(msg_type == 'skproj') spawn(class'AerSN_skjproj');
}

simulated function prohibit_conventional_weapons(){       // AerSN_corpse.uc line 9
   local weapon aw;
   local translator t;
   foreach allactors(class'weapon',aw){
     if(bool(aerwpn(aw))) continue;
     aw.ambientglow = 128;
     aw.setcollision(false,false,false);
   }
   foreach allactors(class'translator',t){
     if(bool(aerwk_tds(t))) continue;
     t.destroy();
   }
}

function TravelPreAccept(){
   if(Pawn(Owner).FindInventoryType(class) == None) Super.TravelPreAccept();
   aer_setup();
   owner_setup();
   level_setup();
}

/*
simulated event travelpostaccept(){
   super.travelpostaccept();
//   postbeginplay();
}
  */
simulated function postbeginplay(){
   aer_setup();
   owner_setup();
   level_setup();
   if(canvas_finfo == none) canvas_finfo = spawn(class'AerGr_FI');
}

function playselect(){
//   local pawn p;
   aer_setup();
   owner_setup();
//   for(p=level.pawnlist; p!=none; p=p.nextpawn) if(bool(skaarj(p))) p.combatstyle = -1;  // todo move this to aerhurt
}

function level_setup(){
   local decoration d;
   local pawn p;
   local byte i;
   assign_spawn_notify('blood');
// assign_spawn_notify('trail');
   assign_spawn_notify('corpse');
   assign_spawn_notify('skproj'); // todo use small projs for skaarjrifle, keep regular skjscouts as usual
   prohibit_conventional_weapons();
   foreach allactors(class'decoration',d) d.bUseMeshCollision=true;
   foreach allactors(class'pawn',p) p.bUseMeshCollision=true;
   for(i=0;i<3;i++){
      if(FirePlayers[i]!=none) continue;
      FirePlayers[i] = spawn(class'AerGR_FP',,,location);
      if(FirePlayers[i]!=none){
         FirePlayers[i].setbase(self);
//         FirePlayers[i].w = self;
      }
//    broadcastmessage(FirePlayers[i]);
   }
}

function owner_setup(){
   local playerpawn p;
   local int fovdiff;
   p = playerpawn(owner);
   bOwnsCrosshair = true;
   if(UserSetFOV > 135) UserSetFOV = 135;
   if(UserSetFOV <  75) UserSetFOV =  75;
   initial_fov = UserSetFOV;
   initial_mousesens = 1.0;
   if(p == none) return;
// p.myhud.hudscaler = 2.0;
   if(lightbeam == none) lightbeam = spawn(class'AerGr_light',p);
//   if(p != none )  initial_mousesens = p.default.mousesensitivity;  // old code
//   if(p != none && bautomapkeys){
   initial_mousesens = p.default.mousesensitivity;  // todo idea:
                                                    // mb store initial_mousesens in ticking inventory
                                                    // will be conflicting with other mousesens-altering weapons
   if(bautomapkeys){
      initial_mousesens = p.mousesensitivity;
      p.consolecommand("set input "$mapforcedodgekeyname$" aerforcedodge");
      p.consolecommand("set input mousewheeldown aerscrolldown");
      p.consolecommand("set input mousewheelup aerscrollup");
      p.consolecommand("set input n aerneedammo");
      p.consolecommand("set input m aerneedbatt");
      p.consolecommand("set input middlemouse aertogglelaser");
      p.consolecommand("set input h aeremi");
      p.consolecommand("set input j aernoemi");
      p.consolecommand("set input o aerpos");
      p.consolecommand("set input p aerwhere");
      if(UserSetFOV >= 85 && UserSetFOV <= 95) return;
      fovdiff = UserSetFOV - 90;
      playerviewoffset.z = -1556 /* was -2050 */  - (fovdiff * 34); // -2100 (was -2825) @ 105deg
                                     // ??? maybe affect x
   }
/*  playerviewoffset.x = -300;
    playerviewoffset.y = 900;
    playerviewoffset.z = -1500; */
}

exec function AERToggleScreen(){
   local int fovdiff;
   if(!validate_owner_toggle()) return;
   if(UserSetFOV > 135) UserSetFOV = 135;
   if(UserSetFOV <  75) UserSetFOV =  75;
   fovdiff = UserSetFOV - 90;
   bZoomScreen = !bZoomScreen;
   if(bZoomScreen){
      PlayerViewOffset.x=5300.0;
      PlayerViewOffset.y=-370.0;
      playerviewoffset.z = -1556 - (fovdiff * 34);
   }else{
      playerviewoffset.x = 3400;
      playerviewoffset.y = -200;
      playerviewoffset.z = -600;
   }
}

function aer_setup(){
   local bool wcfg;
   local byte i;
   give_aer_slaveitems();
   wcfg = false;
   // --------------------------------------------------------------------------------------------------------------
   scanline=0;
   maxdist=4000;
   do_apscan_clr();
   // --------------------------------------------------------------------------------------------------------------
   for(i=0;i<penmon_capacity;i++){                          // blank penmon
      penetrability_monitor[i]._rem = 0;
      penetrability_monitor[i]._full = 0;
      penetrability_monitor[penmon_capacity]._admg = 0;
   }
   // --------------------------------------------------------------------------------------------------------------
   for(i=0;i<2;i++) aux_oper_msg[i] = "";
   setup_menu_hdr = "";
   for(i=0;i<7;i++) setup_menu_line[i] = "";
   // --------------------------------------------------------------------------------------------------------------
   if(transmsg_receiver==none){
      for(i=0;i<translator_max_rows;i++)                    // blank message buffer
         transmsg_screendata[i] = "";
      transmsg_screendata[6]  = "      UMS Translator silicon      ";     // empty translator message
      transmsg_screendata[7]  = "      Data buffer empty.          ";
      transmsg_applied_scroll = 0;
      transmsg_remain_scroll = 0;
/*   "because the garbage collector will"   // transmsg data format
     "[>0100m;                eventually"   // with placeholders
     "[>0101m;                hunt them "   // example without EOLs
     "[>0102m;                down when "
     "[>0103m;                they beco-"   // EOL converter: unr2txt.html (added in zip)
     "[>0104m;                me unrefe-"
     "[>0105m;                renced.   "
     "[>0106m;                This      "
     "[>0107m;                approach  "
     "has the side effect of latent de- "
     "letion of unreferenced objects;   "
     "however it is far more efficient  "
     "than reference counting in the    "
     "case of infrequent deletion."         */
   }
   // --------------------------------------------------------------------------------------------------------------
   for(i=0;i<radar_max;i++){
      radar[i].x=0; radar[i].y=0; radar[i].r=0; radar[i].g=0; radar[i].b=0;
      radar[i].ena=false; radar[i].hit=false; radar[0].t='';
   }
   if(MapForceDodgeKeyName == ""){
      MapForceDodgeKeyName = "Alt";
      wcfg = true;
   }
   UserSetFOV = 90;      // default if not configured
   newfov = UserSetFOV;
   if(!wcfg) return;
   saveconfig();
}

/*function bool ReplaceWith(actor Other, string aClassName){       // unused
        local Actor A;
        local class<Actor> aClass;
        aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
        if(aClass == None) return false;
        A = Other.Spawn(aClass,,Other.Tag,,,None);
        if(A == None) return false;
        if(Other.IsA('Inventory') && Inventory(Other).myMarker != None){
                Inventory(Other).MyMarker.markedItem = Inventory(A);
                if(Inventory(A) != None) Inventory(A).myMarker = Inventory(Other).myMarker;
                Inventory(Other).myMarker = None;
        }
        A.event = Other.event;
        A.tag = Other.tag;
        return true;
}*/

function AERScrollTrigSet(){
   mwheel_trig++;
   decline_timer._untrig = level.timeseconds;
}
function AERScrollTrigClr(){
   mwheel_trig = 0;
   decline_timer._untrig = level.timeseconds - 2.0;
}

function AERScrollProcess(bool dir_up){
   local translatorevent tmp_transmsg;
   local bool tmp_bool;
   local int scroll_delta;
   local pawn p;
   p = pawn(owner);
   if(p == none) return;
   if(p.weapon != self) return;
   if(ena_translator) goto ctl_tds;
   if(ena_areamap) goto ctl_areamap;
   /* -------------------------------------------------------------- */  // ctl_weapon, default
   if(last_scrollproc_updir != dir_up) AERScrollTrigClr(); else AERScrollTrigSet();
   last_scrollproc_updir = dir_up;
   if(mwheel_trig < 8) return;
   switch(aux_oper){
      case 1: if(dir_up){ if(forcefield[0] == none && power_chg>0 && ava_ffield) query_forcefield(0,1); }
               else                                                              query_forcefield(0,0);
              AERScrollTrigClr();                                                                         break;
      case 2: if(dir_up){ if(forcefield[1] == none && power_chg>0 && ava_ffield) query_forcefield(1,1); }
               else                                                              query_forcefield(1,0);
              AERScrollTrigClr();                                                                         break;
      case 3: if(dir_up == ena_invis){
                 AERScrollTrigClr();
                 return;
              }
              if(!ena_invis){
                 laser_upon_invis = ena_laser;
                 query_invis(true);
              }else{
                 if(laser_upon_invis) query_laser(true,true);
                  else query_invis(false);
              }
              AERScrollTrigClr();                                                                         break;
      case 4: if(pw_sens_altfire){
//               ena_auto_powershot = dir_up;   // 2025-01-01: removed. this code allow toggling alt feature
//               if(ena_auto_powershot){                    // if rightmouse held while AERScrollProcess() call
//                  decline_timer._unwarnom = level.timeseconds;
//                  aux_oper_msg[1] = "Auto 3x power first shot.";
//                  warn_opermsg = true;
//               }
              }else{
                 ena_fast_shield = !dir_up;
                 if(!ena_fast_shield){
                    decline_timer._unwarnom = level.timeseconds;
                    aux_oper_msg[1] = "Sniper mode: shield disabled.";
                    warn_opermsg = true;
                    decline_timer._initscan = level.timeseconds;
                 }
                 ena_apscan = false;     // this must be always reset
                 do_apscan_clr();
              }
              AERScrollTrigClr();                                                                         break;
   }
   return;
   /* -------------------------------------------------------------- */  ctl_tds:
   if(tds_oper==0){
      tmp_transmsg = transmsg_receiver.getmessage();
      if(dir_up) transmsg_receiver.NextHistory();     // up = earlier msgs
       else      transmsg_receiver.PrevHistory();
      if(tmp_transmsg != transmsg_receiver.getmessage()){
         transmsg_applied_scroll = 0;
         query_trans_msg_data();
      }
   }else{
      tmp_bool = dir_up ? (transmsg_applied_scroll>0 && transmsg_applied_scroll>=translator_max_cols)
                        : (transmsg_remain_scroll>0);
      scroll_delta = dir_up ? -translator_max_cols
                            :  translator_max_cols;
      if(tmp_bool){
         transmsg_applied_scroll += scroll_delta;
         query_trans_msg_data();
      }
   }
   return;
   /* -------------------------------------------------------------- */  ctl_areamap:
   return;
}

exec function AERScrollUp(){   AERScrollProcess(true);  }
exec function AERScrollDown(){ AERScrollProcess(false); }

/*
function weaponswitch_fuckaround(){
   local playerpawn p;
   p = playerpawn(owner);
   if(p == none) return;
   if(p.pendingweapon == none) p.pendingweapon = self;
   if(p.pendingweapon != self) p.pendingweapon = self;
   if(p.weapon!=none && p.weapon!=self) p.weapon = self;
} */

// todo max override bringup(), putdown() functions. keep an eye on bReadingMessage criteria (mb snipe==false && transmsg proximity)

exec function AERToggleLight(){
   if(!validate_owner_toggle()) return;
   if(lightbeam == none) return;
   if(lightbeam.LightType == LT_None && ava_laser){
      lightbeam.LightType = LT_Steady;
      //todo playsound
   }else{
      lightbeam.LightType = LT_None;
      //todo playsound
   }
}

function do_shutdown_translator(){
   ena_translator = false;
}
function do_shutdown_areamap(){
   ena_areamap = false;
}

exec function AERToggleAreaMap(){
   if(!validate_owner_toggle()) return;
   if(trans_msg_areasign) return;
   do_shutdown_translator();
   ena_areamap = !ena_areamap;
}

exec function aerpos(){
   if(!validate_owner_toggle()) return;
   pos_objective = owner_location;
   ava_objective = true;
   aerwhere();
}

exec function aerwhere(){
   if(!validate_owner_toggle()) return;
   if(!ava_objective) return;
   decline_timer._unobj = level.timeseconds;
   ena_objective = true;
}

exec function aerclk(){  // debug
   ena_cloak = true;
}

exec function aeremi(){ // debug
   ena_emi = true;
   decline_timer._reffsta[0] = level.timeseconds - 1.8;
   decline_timer._reffsta[1] = level.timeseconds - 1.8;
   query_forcefield(0,0);
   query_forcefield(1,0);
   collapse_shield();
   query_invis(false);
   query_laser(false,false);
}
exec function aernoemi(){ // debug
   ena_emi = false;
}

exec function aerneedammo(){ // debug
//   ammo_chg=ammo_max;
  if(ammo_chg <= 600) ammo_chg += 120;
}

exec function aerneedbatt(){ // debug
   if(batt_chg<batt_full) batt_chg += batt_clip;
   if(batt_chg>batt_full) batt_chg  = batt_full;
}

function query_progress_ammo(byte newmaxsel){
   local int ammomaxdecision;
                      ammomaxdecision = 1;
   if(newmaxsel == 2) ammomaxdecision = 2;
   if(newmaxsel == 3) ammomaxdecision = 3;
   ammo_max = 240 * ammomaxdecision;
}
function query_progress_cloak(){ ena_cloak = true; }
function query_progress_synth(){ ena_synth = true; }
function query_progress_batt(){  ena_powercell = true; }

function query_invis(bool newstate){
   local playerpawn p;
   local Inventory S;
   local effects e;
   local sound trigsnd;
   if(owner == none || ena_emi){
      ena_invis = false;
      return;
   }
   p = playerpawn(Owner);
   if(p == None) return;
   if(newstate == ena_invis) return;                    // already this state
   if(newstate && power_chg < 3 && ava_invis) return;   // min charge to enter
   if(newstate) query_laser(false,true);                // invis shutdowns laser           
   ena_invis = newstate;
   S = p.FindInventoryType(class'ShieldBelt');
   if(s != none) e = Shieldbelt(S).MyEffect;
   if(e != none) e.bHidden = ena_invis;
   trigsnd = ena_invis ? Sound'aerinvsta' : Sound'aerinvend';
   owner.playsound(trigsnd, SLOT_None, 4);
   p.Visibility = ena_invis ? 0 : p.Default.Visibility;    // todo:
                                                           //   move this to tick() and handle crouching
                                                           //   for variable, non asyncronous visibility
   self.bOnlyOwnerSee = !ena_invis;                     // NFI of this but it need for smth AI
   if(ena_invis){
//    self.SetDisplayProperties(STY_Translucent, FireTexture'Unrealshare.Belt_fx.Invis', true, true);
//      Owner.SetDisplayProperties(STY_Translucent, FireTexture'unrealshare.Belt_fx.Invis', false, true);
      MultiSkins[0] = Texture'unrealshare.Belt_fx.Invis';
      MultiSkins[1] = Texture'unrealshare.Belt_fx.Invis';
      MultiSkins[2] = Texture'unrealshare.Belt_fx.Invis';
      Style = STY_Translucent;
      bUnlit = true;
//      bMeshEnviromap = false;     // not working
      p.bHidden = True;
      return;
   }else{
      self.SetDefaultDisplayProperties();
      Owner.SetDefaultDisplayProperties();
      MultiSkins[0] = Texture'AER.Skin.aercoat';
      MultiSkins[1] = Texture'AER.Skin.aermtl';
      MultiSkins[2] = Texture'AER.Skin.aermtlb';
      Style = STY_Normal;
      bUnlit = false;
//      bMeshEnviromap = false;
      if(p.health>0) p.bHidden = False;
   }
}

exec function aertogglelaser(){
   if(!validate_owner_toggle()) return;
   if(ena_laser){
      query_laser(false,true);
   }else{
      if(ava_laser && !ena_emi) query_laser(true,true);
   }
}

function query_forcefield(byte nfield,byte newstate){
   local rotator pawnrot;
   local vector x,y,z,field_origin,endtrace,hitloc,hitnor;
   local vector field_maxbot, field_maxtop, field_maxleft, field_maxright;
   local bool usable_maxbot, usable_maxtop, usable_maxleft, usable_maxright;
   local bool field_possible, field_y_set, field_z_set;
   local byte field_consume_level,field_consume_horz;
   local float field_w,field_h;
   if(state_forcefield[nfield]==newstate) return;
   if(level.timeseconds - decline_timer._reffsta[nfield] < 1.7) return;
   decline_timer._reffsta[nfield] = level.timeseconds;
   field_possible = false;
   if(!newstate){
      if(forcefield[nfield]!=none) forcefield[nfield].ena_collapse=true;
      forcefield[nfield]=none;
      state_forcefield[nfield]=0;
      return;
   }
   if(pawn(owner)==none || ena_emi) return;
   pawnrot=pawn(owner).viewrotation;
   getaxes(pawnrot,x,y,z);
   field_origin = pawn(owner).location + 160.0*x;
   if(sensed_forcefield_attractor != none){                          // hull presetted in level
      if(sensed_forcefield_attractor.group != ''){                   // this hull occupied
         field_possible = false;
         goto field_setup_done;
      }
      field_origin = sensed_forcefield_attractor.location;
      pawnrot = sensed_forcefield_attractor.rotation;
      field_w = sensed_forcefield_attractor.collisionRadius*2;
      field_h = sensed_forcefield_attractor.collisionHeight*2;
      field_possible = true;
      goto field_setup_done;
   }
   if(range < 160){                      // pointing too close to wall, abort
      field_possible = false;
      goto field_setup_done;
   }
   pawnrot.pitch = -16384;
   endtrace = field_origin + 128 * vector(pawnrot);
   trace(hitloc,hitnor,endtrace,field_origin,true);
   field_origin=hitloc+40*z; // approx 85 cm from floor
   pawnrot.pitch = -16384;                                                // hull diagnostics, trace down
   endtrace = field_origin + 160 * vector(pawnrot); // was 192                 // ??? shit: we trace twice,
   field_maxbot = vect(32767,32767,32767);                                     // but still have incorrect z. todo diag all ffield vars
   trace(field_maxbot,hitnor,endtrace,field_origin,true);                      // p.viewrot+160*x may be in solid floor
   usable_maxbot = vsize(field_maxbot - field_origin) <= 80;  //was 96, half of endtrace dist
   pawnrot.pitch=16384;                                                   // up
   endtrace = field_origin + 160 * vector(pawnrot); // was 192
   field_maxtop = vect(32767,32767,32767);
   trace(field_maxtop,hitnor,endtrace,field_origin,true);
   usable_maxtop = vsize(field_maxtop - field_origin) <= 80;
   pawnrot.pitch=0;                                                       // left
   pawnrot.yaw-=16384;
//   field_tmp_maxleft = !boost_power ? 128 : 192;  // shit: this don't working as intended, removed
   endtrace = field_origin + 256 * vector(pawnrot); // was 384
   field_maxleft = vect(32767,32767,32767);
   trace(field_maxleft,hitnor,endtrace,field_origin,true);
   usable_maxleft = vsize(field_maxleft - field_origin) <= 128; // half of entrace
   pawnrot.yaw+=32768;                                                    // right
   endtrace = field_origin + 256 * vector(pawnrot); // was 384
   pawnrot.yaw-=16384;                                                    // restore dir for spawn usage
   field_maxright = vect(32767,32767,32767);
   trace(field_maxright,hitnor,endtrace,field_origin,true);
   usable_maxright = vsize(field_maxright - field_origin) <= 128;
   if(usable_maxleft && usable_maxright) field_w = vsize(field_maxleft - field_maxright);   else field_w = 256;  // was 384
   if(usable_maxtop && usable_maxbot)    field_h = vsize(field_maxtop - field_maxbot);      else field_h = 160;  // was 192
   field_y_set = false;
   if(usable_maxleft){
      field_origin  = field_maxleft;
      field_origin += (field_w/2) * y;
      field_y_set = true;
   }
   if(usable_maxright && !field_y_set){
      field_origin  = field_maxright;
      field_origin -= (field_w/2) * y;
   }
   field_z_set = false;
   if(usable_maxbot){
      field_origin.z  = field_maxbot.z;
      field_origin.z += (field_h/2);
      field_z_set = true;
   }
   if(usable_maxtop && !field_z_set){
      field_origin.z  = field_maxtop.z;
      field_origin.z -= (field_h/2);
   }
   if(usable_maxtop || usable_maxbot) field_possible = true;
   if(field_w < 0.5 || field_h < 0.5) field_possible = false;
   field_setup_done:
   if(field_possible){
      query_invis(false);
      forcefield[nfield] = spawn(class'AerGr_ffield', owner, '', field_origin, pawnrot); // big fields

      broadcastmessage("OL:" $ owner_location);
      broadcastmessage("FW:" $ field_w);
      broadcastmessage("FH:" $ field_h);

   }
   if(forcefield[nfield] == none){
      decline_timer._unwarnom = level.timeseconds;
      aux_oper_msg[0] = "Forcefield sustain impossible:";
      aux_oper_msg[1] = "no EMR or 100% drain in area.";
      warn_opermsg = true;
      Owner.PlaySound(Sound'aerffend', SLOT_None, 4);       // shield field do not cause sounds
   }else{
      dist_field[nfield]=0;                                 // todo this need rebalance, we reduced 192x384 field to 128x192
      Owner.PlaySound(Sound'aerffsta', SLOT_None, 4);
      forcefield[nfield].ambientsound = Sound'aerffloop';
      forcefield[nfield].field_w = field_w;    //  --96--|--96--|--96--|--96--  \ 
      forcefield[nfield].field_h = field_h;    // | CL1  |  2   |  3   |  4   |  64
                      field_consume_horz = 1;  //  ------+------+------+------  /  
      if(field_w>96)  field_consume_horz++;    // | CL2  |  2x                |
      if(field_w>192) field_consume_horz++;    // | CL3  |  3x                |
      if(field_w>288) field_consume_horz++;    //  ------|------|------|------
                      field_consume_level  = field_consume_horz;
      if(field_h>64)  field_consume_level += field_consume_horz;
      if(field_h>128) field_consume_level += field_consume_horz;   // 4x3 = 12 max
      forcefield[nfield].field_consume_level = field_consume_level;
      if(sensed_forcefield_attractor != none) forcefield[nfield].field_hull = sensed_forcefield_attractor;
      state_forcefield[nfield]=1;
      forcefield[nfield].proj_reactive = (nfield==1); // true for F2
   }
}

function query_laser(bool newstate, bool notifysound){
   if(newstate == ena_laser) return;
   if(newstate) query_invis(false);                // laser shutdowns invis
   ena_laser=newstate;
   if(ena_laser && laserdot==none && !ena_emi){
      laserdot=spawn(class'AerGr_laser',owner);
      laserdotsec=spawn(class'AerGr_laser',owner);
//    laserdot.instigator=none;
//    laserdotsec.instigator=none;
      ena_laser = true;
      if(notifysound) owner.playsound(sound'aerlaseron', SLOT_Misc, 96);
      return;
   }
   if(!ena_laser && laserdot!=none){
      laserdot.destroy();
      laserdot=none;
      laserdotsec.destroy();
      laserdotsec=none;
      ena_laser = false;
      if(notifysound) owner.playsound(sound'aerlaseroff', SLOT_Misc, 96);
   }
}

exec function aerforcedodge(){
   local playerpawn p;            // required. pawns do not have bWASD controller memory
   p = playerpawn(owner);
   if(p == none) return;
   if(p.weapon != self) return;   // no validate_owner_toggle() call bc we need p anyway
   xdir = 0;
   ydir = 0;
   if(p.bwasforward) xdir = 1;
   if(p.bwasback)    xdir = -1;
   if(p.bwasleft)    ydir = 1;
   if(p.bwasright)   ydir = -1;
   if(xdir == 0 && ydir == 0){
      return;
      // todo light toggles here
   }
   if(fast_shield_chg <= shield_per_dodge) return;
   if(!InfiniteDodge) do_shield_degrade(shield_per_dodge);
   performdodge(p);
}

exec function aersavecfg(){
   saveconfig();
   if(pawn(owner) != none) pawn(owner).clientmessage("AER configuration saved.", 'Pickup');
}

function bool validate_owner_toggle(){
   local pawn p;
   p = pawn(owner);
   if(p == none) return false;
   if(p.weapon != self) return false;
   return true;
}

function performdodge(playerpawn p){
   local vector x, y, z;
   local rotator r;
   if(p.Physics == PHYS_Walking && (xdir != 0 || ydir != 0)){
      getaxes(p.rotation, x, y, z);
      p.velocity = (xdir*1.5*p.groundspeed+p.velocity dot x)*x + (ydir*1.5*p.groundspeed+p.velocity dot y)*y;
      p.velocity.z = 160;
      p.PlayOwnedSound(p.JumpSound, SLOT_Talk, 1.0, true, 800, 1.0);
      if(xdir == 0){
         if(ydir == 1)  p.PlayDodge(DODGE_Left);
         if(ydir == -1) p.PlayDodge(DODGE_Right);
      }else{
         if(xdir == -1) p.PlayDodge(DODGE_Back);
         if(xdir == 1)  p.PlayDodge(DODGE_Forward);
      }
      p.SetPhysics(PHYS_Falling);
   }else if(p.Physics == PHYS_Swimming){
      if(!forced) return;
      p.waterspeed = 45000;
      p.Velocity = vector(p.viewrotation) * 2000;
      r = p.viewrotation;
      r.pitch = r.pitch % 65536;
      if(r.pitch > 32768) r.pitch -= 65536;
      if(r.pitch > 3000) p.Velocity.Z = 640;
      forced = false;
      decline_timer._redodge = level.timeseconds;
   }
}

function translatorevent FindTransEvent(){
   local translatorevent t,t_res;
   t_res = none;
   foreach RadiusActors(class'translatorevent', t, 128)                           // primary, look by trans property set
      if(transmsg_receiver!=none && t.trans==transmsg_receiver) t_res = t;
   if(t_res != none) goto skip_findtransevent_passtwo;
   foreach RadiusActors(class'translatorevent', t, 256)                           // secondary, look by proximity
      if(vsize(t.location-owner_location) <= t.CollisionRadius * 2.2
                                 && t.trans==transmsg_receiver) t_res = t;
   skip_findtransevent_passtwo:
   if(t_res != none){
      transmsg_proximity = true;
      transmsg_last_known = t_res;
      decline_timer._hidemsg = level.timeseconds;
   }
   return t_res;                                                                  // none if failed
}

function triggers FindAERTrigger(vector search_location, float range_sensitivity, bool ignore_collision){
   local triggers t;
   foreach RadiusActors(class'triggers', t, range_sensitivity){
      if(ignore_collision) return t;
      if(vsize(t.location-search_location) <= t.CollisionRadius) return t;
   }
   return none;
}

function pawn FindPawn(name t){
   local pawn pt;
   for(pt=level.pawnlist; pt!=none; pt=pt.nextpawn) if(pt.name == t) return pt;
   return none;
}

function areamapdata FindAMD(){
   local areamapdata a;
   foreach allactors(class'areamapdata', a) return a;
   return none;
}

function consume_main_cell_heavy(int c_amount){
   decline_timer._rechrg = level.timeseconds;
   if(batt_chg >= c_amount) batt_chg -= c_amount;
    else batt_chg = 0;
}

function consume_main_cell(int c_amount){
   if(batt_chg >= c_amount) batt_chg -= c_amount;
    else batt_chg = 0;
}

function charge_main_cell(int c_amount){
   if(boost_power) goto skip_batt_cooling;
   if(level.timeseconds - decline_timer._rechrg < 2.5) return;
   skip_batt_cooling:
   if(batt_chg < batt_full) batt_chg += c_amount;
    else batt_chg = batt_full;
}

function give_aer_slaveitems(){
   local playerpawn p;
   local AerAm_core c;
   local AerAm_shard s;
   local AerWk_TDS t;
   if(owner == none) return;
   p = playerpawn(owner);
   if(p == none) return;
   c = AerAM_core(p.findinventorytype(class'AerAm_core'));
   if(c == none){
      c = spawn(class'AerAm_core',,,vect(32767,32767,32767));
      p.addinventory(c);
      c.becomeitem();
      c.gotostate('idle2');
   }
   s = AerAM_shard(p.findinventorytype(class'AerAm_shard'));
   if(s == none){
      s = spawn(class'AerAm_shard',,,vect(32767,32767,32767));
      p.addinventory(s);
      s.becomeitem();
      s.gotostate('idle2');
   }
   t = AerWk_TDS(p.findinventorytype(class'AerWk_TDS'));
   if(t == none){
      t = spawn(class'AerWk_TDS',,,vect(32767,32767,32767));
      p.addinventory(t);
      t.becomeitem();
      t.gotostate('idle2');
   }
   transmsg_receiver = t;
   transmsg_receiver.w = self;
}

exec function aercfg(){
   local vector l,x,y,z;
   local rotator r;
   local aercfgkey k;
   if(!validate_owner_toggle()) return;
   query_invis(false);
   query_forcefield(0,0);
   query_forcefield(1,0);
   collapse_shield();
   query_laser(true,true);
   if(entering_setup || ena_setup) return;
   entering_setup = true;
   ena_setup = true;
   setup_room_qc = 0;
   r = owner_viewrotation;
   l = owner_location;
   getaxes(r,x,y,z);
   k = spawn(class'aercfgkey',,,l +220*x   +10*y   +20*z,  r);
   if(k != none){ k.w = self; k.aerkey_oper=5; k.mesh=Mesh'aerkey_esc'; setup_room_qc++; }
   k = spawn(class'aercfgkey',,,l +220*x   +100*y  +10*z,  r);
   if(k != none){ k.w = self; k.aerkey_oper=6; k.mesh=Mesh'aerkey_ent'; setup_room_qc++; }
   k = spawn(class'aercfgkey',,,l +220*x   +50*y   +20*z,  r);
   if(k != none){ k.w = self; k.aerkey_oper=1; k.mesh=Mesh'aerkey_up';  setup_room_qc++; }
   k = spawn(class'aercfgkey',,,l +220*x   +30*y   +0*z,   r);
   if(k != none){ k.w = self; k.aerkey_oper=3; k.mesh=Mesh'aerkey_l';   setup_room_qc++; }
   k = spawn(class'aercfgkey',,,l +220*x   +50*y   +0*z,   r);
   if(k != none){ k.w = self; k.aerkey_oper=2; k.mesh=Mesh'aerkey_dn';  setup_room_qc++; }
   k = spawn(class'aercfgkey',,,l +220*x   +70*y   +0*z,   r);
   if(k != none){ k.w = self; k.aerkey_oper=4; k.mesh=Mesh'aerkey_r';   setup_room_qc++; }
   seq_hello = 0;
   btn_origin = l;
   decline_timer._readvhello = level.timeseconds;
}

// ----------------------------------------------------------------------------------------------------------------------
// These functions called very seldom and won't impact performance, also I'm too stupid for optimizing them.
// So we can code here any kind of 8x nested shit and multiple repeating checks.
// ----------------------------------------------------------------------------------------------------------------------
function aercfg_acceptkey(byte oper){
   local playerpawn p;
   p=playerpawn(owner);
   if(p==none) return;
   if(entering_setup || !ena_setup) return;
   if(cmos_mode == 0){
      if(oper == 1 && cmos_sel > 0) cmos_sel--;
      if(oper == 2 && cmos_sel < 5) cmos_sel++;
      if(oper == 5){
         aercfg_killkey();
         ena_setup = false;
      }
      if(oper == 6){
         cmos_mode = cmos_sel+1;   // enter submenu
         cmos_sel = 0;
      }
      return;
   }
   if(cmos_mode >= 1 && cmos_mode <= 6){  //todo: mb 7
      if(oper == 1 && cmos_sel > 0)            cmos_sel--;
      if(oper == 2 && cmos_sel < cmos_sel_max) cmos_sel++;
      if(oper == 3) aercfg_modify(false);
      if(oper == 4) aercfg_modify(true);
      if(oper == 5){
         cmos_sel = cmos_mode-1;   // leave submenu
         cmos_mode = 0;
      }
      if(cmos_mode == 6 && oper == 6){         // commands in exitmenu
         if(cmos_sel == 0){
            saveconfig();
            aercfg_killkey();
            ena_setup = false;
         }
         if(cmos_sel == 1){
            aercfg_killkey();
            ena_setup = false;
         }
         if(cmos_sel == 2) aercfg_defaults(0);
         if(cmos_sel == 3) aercfg_defaults(1);
         if(cmos_sel == 4) aercfg_defaults(2);
      }
      if(cmos_mode == 2 && cmos_sel == 5 && oper == 6){      // select dodge key
         // mode = 7;
      }
      return;
   }
}
function aercfg_update_menu(){
   local string sel_prefix[7],state1str,state2str,state3str;
   local byte i;
   if(!ena_setup || entering_setup) return;
   for(i=0; i<7; i++) if(cmos_sel == i) sel_prefix[i] = " >"; else sel_prefix[i] = "  ";
   if(cmos_mode == 0){
      setup_menu_hdr="";
      setup_menu_line[0]="Performance";
      setup_menu_line[1]="Input/click speed";
      setup_menu_line[2]="Interface";
      setup_menu_line[3]="Balance";
      setup_menu_line[4]="Extra features";
      setup_menu_line[5]="Exit/presets";
      setup_menu_line[6]="";
   }
   if(cmos_mode == 1){
      cmos_sel_max = 2;  // qty minus 1, aka last allowed index
      state1str = "20 PPS";
      if(RadarScanInterval <= 1) state1str = "10 PPS";
      if(RadarScanInterval >= 3) state1str = "max";
      setup_menu_hdr="                Performance";
      setup_menu_line[0]="(-) radar pollrate: "$state1str;
      setup_menu_line[1]="";
      setup_menu_line[2]="";
      setup_menu_line[3]="";
      setup_menu_line[4]="";
      setup_menu_line[5]="";
      setup_menu_line[6]="";
   }
   if(cmos_mode == 2){
      cmos_sel_max = 5;
      setup_menu_hdr="                Input/click speed";
      setup_menu_line[0]="exec aux (ms):      "$int(RClickExecCmdMax*1000);
      setup_menu_line[1]="select min:         "$int(RClickChgModeMin*1000);
      setup_menu_line[2]="       max:         "$int(RClickChgModeMax*1000);
      setup_menu_line[3]="exec alt min:       "$int(RClickExecAltCmdMin*1000);
      setup_menu_line[4]="         max:       "$int(RClickExecAltCmdMax*1000);
      setup_menu_line[5]="onetap dodge:       "$MapForceDodgeKeyName;
      setup_menu_line[6]="";
   }
   if(cmos_mode == 3){
      cmos_sel_max = 4;
      setup_menu_hdr="                Interface";
      setup_menu_line[0]="msg hide after:     "$int(HideMsgInterval*1000);
      setup_menu_line[1]="calibrate to FOV:   "$UserSetFOV;
      setup_menu_line[2]="";
      setup_menu_line[3]="";
      setup_menu_line[4]="";
      setup_menu_line[5]="";
      setup_menu_line[6]="";
   }
   if(cmos_mode == 4){
      cmos_sel_max = 6;
      state1str = DisablePushCorridorBalance ? "pipe (fun)" : "cone (real)";
      state2str = InfiniteDodge ? "off" : "on";
      state3str = InfiniteAmmo ? "inf." : string(ammo_max);
      setup_menu_hdr="                Balance";
      setup_menu_line[0]="fire rate:          "$int(60/BaseFireInterval)$" RPM";
      setup_menu_line[1]="power restore:      "$int(60/BaseRepowerInterval)$" CPM";
      setup_menu_line[2]="airvortex corridor: "$state1str;
      setup_menu_line[3]="          recharge: "$int(PushInterval*1000);;
      setup_menu_line[4]="radar sens:         ";     //todo
      setup_menu_line[5]="dodge powercost:    "$state2str;
      setup_menu_line[6]="ammo:               "$state3str;
   }
   if(cmos_mode == 5){
      cmos_sel_max = 2;
      state1str = DisableReader  ? "off" : "on";
      state2str = DisableHitsens ? "off" : "on";
      setup_menu_hdr="                Extra features";
      setup_menu_line[0]="message reader:     "$state1str;
      setup_menu_line[1]="hit sensor:         "$state3str;
      setup_menu_line[2]="";
      setup_menu_line[3]="";
      setup_menu_line[4]="";
      setup_menu_line[5]="";
      setup_menu_line[6]="";
   }
   if(cmos_mode == 6){
      cmos_sel_max = 4;
      setup_menu_hdr="                Exit";
      setup_menu_line[0]="save changes";
      setup_menu_line[1]="discard changes";
      setup_menu_line[2]="load factory defaults";
      setup_menu_line[3]="load ez defaults";
      setup_menu_line[4]="load unbroken 227 defaults";
      setup_menu_line[5]="";
      setup_menu_line[6]="";
   }
   for(i=0; i<7; i++) setup_menu_line[i] = sel_prefix[i]$setup_menu_line[i];
}
function aercfg_modify(bool incval){
   local bool grp_perform,grp_input,grp_iface,grp_balance,grp_extra;
   grp_perform = cmos_mode == 1;
   grp_input   = cmos_mode == 2;
   grp_iface   = cmos_mode == 3;
   grp_balance = cmos_mode == 4;
   grp_extra   = cmos_mode == 5;
   //  group          command           oper           var                validation                               halt
   if(grp_perform && cmos_sel == 2 && !incval){ RadarScanInterval--; if(RadarScanInterval<1) RadarScanInterval=1; return; }
   if(grp_perform && cmos_sel == 2 &&  incval){ RadarScanInterval++; if(RadarScanInterval>3) RadarScanInterval=3; return; }
/*        if(grp_input   && cmos_sel == 0) RClickExecCmdMax  0.16      // todo modify clickspeeds, not implemented yet
        if(grp_input   && cmos_sel == 1) RClickChgModeMin  0.25
        if(grp_input   && cmos_sel == 2) RClickChgModeMax  0.50
        if(grp_input   && cmos_sel == 3) RClickExecAltCmdMin 1.00
        if(grp_input   && cmos_sel == 4) RClickExecAltCmdMax 1.80            */
//        if(grp_input && cmos_sel == 5) "onetap dodge:       "$MapForceDodgeKeyName;
   if(grp_iface   && cmos_sel == 0 && !incval){ HideMsgInterval-=0.4;    if(HideMsgInterval<2.0)    HideMsgInterval=2.0;    return; }
   if(grp_iface   && cmos_sel == 0 &&  incval){ HideMsgInterval+=0.4;    if(HideMsgInterval>7.2)    HideMsgInterval=7.2;    return; }
   if(grp_iface   && cmos_sel == 1 && !incval){ UserSetFOV-=5;           if(UserSetFOV<75)          UserSetFOV=75;          return; }
   if(grp_iface   && cmos_sel == 1 &&  incval){ UserSetFOV+=5;           if(UserSetFOV>135)         UserSetFOV=135;         return; }
//   if(grp_balance && cmos_sel == 0 && !incval){ BaseFireInterval+=0.015; if(BaseFireInterval>0.25)  BaseFireInterval=0.25;  return; }
//   if(grp_balance && cmos_sel == 0 &&  incval){ BaseFireInterval-=0.015; if(BaseFireInterval<0.07)  BaseFireInterval=0.07;  return; }
//   if(grp_balance && cmos_sel == 1 && !incval){ BaseRepowerInterval+=0.03; if(BaseRepowerInterval>0.28) BaseRepowerInterval=0.28; return; }
//   if(grp_balance && cmos_sel == 1 &&  incval){ BaseRepowerInterval-=0.03; if(BaseRepowerInterval<0.1)  BaseRepowerInterval=0.1;  return; }
   if(grp_balance && cmos_sel == 2){  DisablePushCorridorBalance =  incval;                                                 return; }
   if(grp_balance && cmos_sel == 3 && !incval){ PushInterval+=0.1;       if(PushInterval>0.7)       PushInterval=0.7;       return; }
   if(grp_balance && cmos_sel == 3 &&  incval){ PushInterval-=0.1;       if(PushInterval<0.2)       PushInterval=0.2;       return; }
   if(grp_balance && cmos_sel == 4 && !incval){ RadarScanRadius-=4000;   if(RadarScanRadius<4000)   RadarScanRadius=4000;   return; }
   if(grp_balance && cmos_sel == 4 &&  incval){ RadarScanRadius+=4000;   if(RadarScanRadius>20000)  RadarScanRadius=20000;  return; }
   if(grp_balance && cmos_sel == 5){            InfiniteDodge    = !incval;                                                 return; }
   if(grp_balance && cmos_sel == 6){            InfiniteAmmo     =  incval;                                                 return; }
   if(grp_extra   && cmos_sel == 0){            DisableReader    = !incval;                                                 return; }
   if(grp_extra   && cmos_sel == 1){            DisableHitsens   = !incval;                                                 return; }
}
function aercfg_defaults(byte preset){
   if(preset == 0){                          // normal
      PushInterval               = 0.7;
      DisablePushCorridorBalance = false;
      InfiniteDodge              = false;
      InfiniteAmmo               = false;
      return;
   }
   if(preset == 1){                          // ez
      PushInterval               = 0.3;
      DisablePushCorridorBalance = true;
      InfiniteDodge              = true;
      InfiniteAmmo               = false;
      return;
   }
   if(preset == 2){                          // fix 227 difficulty=8
      PushInterval               = 0.2;
      DisablePushCorridorBalance = true;
      InfiniteDodge              = true;
      InfiniteAmmo               = true;
      return;
   }
}
// ----------------------------------------------------------------------------- key/mnu proc ends ----------------------
function aercfg_killkey(){
   local aercfgkey k;
   foreach AllActors(class'aercfgkey', k) k.destroy();
}
function aercfg_advance_hello(){
   local bool initfail;
   local pawn p;
   p = pawn(owner);
   if(p == none) return;
   if(!ena_setup) return;
   if(ena_setup && !entering_setup && vsize(p.location-btn_origin) >= 768){
      ena_setup = false;
      aercfg_killkey();
   }
   if(seq_hello >=32) return;
   if(level.timeseconds - decline_timer._readvhello < 0.2) return;   // textanim speed
   decline_timer._readvhello = level.timeseconds;
   seq_hello++;
   initfail = setup_room_qc < 6;
   if(seq_hello >= 20 && initfail) aercfg_killkey();
   if(!initfail && seq_hello >= 10){
      cmos_mode=0;
      cmos_sel=0;
      entering_setup = false;
      aercfg_update_menu();
   }
   if(seq_hello >= 30 && initfail){
      ena_setup = false;
      entering_setup = false;
   }
}

function Destroyed(){
   super.destroyed();
   query_forcefield(0,0);
   query_forcefield(1,0);
   collapse_shield();
   query_invis(false);
   query_laser(false,false);
   aercfg_killkey();
   if(canvas_finfo != none) canvas_finfo.Destroy();
}

defaultproperties{
   transmsg_receiver=none
   anim_dl=0
   UserSetFOV=106
   bZoomScreen=false
   range=0
   zoomfactor=1
   initial_fov=0
   newFOV=0
   xdir=0
   ydir=0
   modem_rssi=0
   deaim_rate=2
   ammo_max=972
   power_chg=0
   ammo_chg=0
   batt_chg=0
   synth_chg=0
   fire_idle_chg=0
   LaserFlags=0
   scale1=0.0
   scale128=0.0
   scale256=0.0
   clipxdiv2=0.0
   clipydiv2=0.0
   initial_mousesens=0.0
   decline_timer_unshock=0.0
   RClickExecCmdMax=0.16
   RClickChgModeMin=0.25
   RClickChgModeMax=0.5
   RClickExecAltCmdMin=0.59
   RClickExecAltCmdMax=1.3
   PushInterval=0.7
   aux_old_yaw=0.0
   cap_process_slowdown=0.0
   HideMsgInterval=0.7
   RadarScanRadius=12000.0
   ForceField(0)=None
   ForceField(1)=None
   shield_blk=None
   populated_shield_dmg=0
   incoming_danger=0
   sensed_forcefield_attractor=None
   canvas_finfo=None
   laserdot=None
   laserdotsec=None
   btn_origin=(X=0.0,Y=0.0,Z=0.0)
   pos_objective=(X=0.0,Y=0.0,Z=0.0)
   ava_objective=false
   MapForceDodgeKeyName="Alt"
   trans_msg_areasign=false
   state_forcefield(0)=0
   state_forcefield(1)=0
   dist_field(0)=0
   dist_field(1)=0
   fast_shield_chg=0
   mwheel_trig=0
   ena_translator=false
   ena_areamap=false
   last_scrollproc_updir=false
   aux_oper=4
   tds_oper=1
   RadarScanInterval=2
   radar_qty=0
   radar_vqty=0
   setup_room_qc=0
   seq_hello=0
   cmos_mode=0
   cmos_sel=0
   cmos_sel_max=0
   cursor_blink_pos=0
   canvas_set=false
   ava_synth=false
   boost_power=false
   InfiniteDodge=false
   forced=True
   InfiniteAmmo=false
   warn_opermsg=false
   ena_fast_shield=true
   ena_emi=false
   DisablePushCorridorBalance=false
   bAutoMapKeys=True
   DisableReader=false
   DisableHitsens=false
   anylock=false
   surelock=false
   hdmlock=false
   low_batt=false
   fired=false
   FirePlayers(0)=None
   FirePlayers(1)=None
   FirePlayers(2)=None
   ena_invis=false
   ena_synth=false
   ena_cloak=false
   ena_powercell=false
   ena_moreammo_2x=false
   ena_moreammo_3x=false
   bMyOwnsCrosshair=false
   snipe=false
   warn_aux=false
   pw_sens_fire=false
   pw_sens_altfire=false
   pw_sens_crouch=false
   ava_laser=false
   ava_invis=false
   ava_ffield=false
   ena_fullauto=true
   ena_laser=false
   inhibit_laser=false
   laser_upon_invis=false
   transmsg_proximity=false
   ignore_hitsens_trig=false
   ignore_hitsens_rst=True
   DisableMenuSound=false
   ena_setup=false
   entering_setup=false
   PickupAmmoCount=9999
   last_firetime=0.0
   AmmoName=Class'AER.AerAm_native'
   DrawScale=0.1
   PlayerViewScale=0.1
   PickupViewScale=0.1
   ThirdPersonScale=0.06
   PlayerViewMesh=Mesh'AER.aerview'
   PickupViewMesh=Mesh'AER.aerpick'
   ThirdPersonMesh=Mesh'AER.aerview'
   PlayerViewOffset=(X=5300.0,Y=-370.0,Z=-2100.0)
   PickupMessage=""
   PickupSound=Sound'aerpickup'
   ItemName="Assault electromagnetic rifle"
   ScaleGlow=3.0
   CollisionRadius=62.4
   CollisionHeight=8.79999
   Mesh=Mesh'AER.aerpick'
   MultiSkins(0)=Texture'AER.Skin.aercoat'
   MultiSkins(1)=Texture'AER.Skin.aermtl'
   MultiSkins(2)=Texture'AER.Skin.aermtlb'
   MultiSkins(3)=ScriptedTexture'AER.Disp.aerscreen'
   bCanThrow=false
   shakemag=0.0
   shaketime=0.0
   shakevert=0.0
}
