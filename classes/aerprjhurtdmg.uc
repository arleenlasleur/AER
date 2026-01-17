class aerprjhurtdmg extends Projectile;
#exec audio import file="sounds\aerflesh1.wav" name="aerflesh1" package="AER" group="Sound"
#exec audio import file="sounds\aerflesh2.wav" name="aerflesh2" package="AER" group="Sound"
#exec audio import file="sounds\aerflesh3.wav" name="aerflesh3" package="AER" group="Sound"
#exec audio import file="sounds\aerflesh4.wav" name="aerflesh4" package="AER" group="Sound"
#exec audio import file="sounds\aerflesh5.wav" name="aerflesh5" package="AER" group="Sound"
#exec audio import file="sounds\aerwall1.wav" name="aerwall1" package="AER" group="Sound"
#exec audio import file="sounds\aerwall2.wav" name="aerwall2" package="AER" group="Sound"
#exec audio import file="sounds\aerwall3.wav" name="aerwall3" package="AER" group="Sound"
#exec audio import file="sounds\aerwall4.wav" name="aerwall4" package="AER" group="Sound"
#exec audio import file="sounds\aerwall5.wav" name="aerwall5" package="AER" group="Sound"
#exec audio import file="sounds\aerwall6.wav" name="aerwall6" package="AER" group="Sound"
#exec audio import file="sounds\aerwall7.wav" name="aerwall7" package="AER" group="Sound"
#exec audio import file="sounds\aerstuff1.wav" name="aerstuff1" package="AER" group="Sound"
#exec audio import file="sounds\aerstuff2.wav" name="aerstuff2" package="AER" group="Sound"

// --------------------------------- used in tracerdmg, todo delete me ---------
#exec obj load file="..\System\UnrealI.u" package="UnrealI"  // todo mbshit
#exec texture import file="textures\skin\aertracer.png" name="aertracer" package="AER" group="Skin" mips=1 flags=0 btc=-2

#exec mesh import mesh="aerbullet3" anivfile="Models\aerbullet3_a.3d" datafile="Models\aerbullet3_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerbullet3" x=0 y=0 z=0
#exec mesh sequence mesh="aerbullet3" seq=All startframe=0 numframes=1
#exec meshmap new meshmap="aerbullet3" mesh=aerbullet3
#exec meshmap scale meshmap="aerbullet3" x=0.06256 y=0.06256 z=0.12512
// --------------------------------- used ends ---------------------------------

//#exec mesh import mesh="aerbullet" anivfile="Models\aerbullet_a.3d" datafile="Models\aerbullet_d.3d" x=0 y=0 z=0 mlod=0
//#exec mesh origin mesh="aerbullet" x=0 y=0 z=0
//#exec mesh sequence mesh="aerbullet" seq=All startframe=0 numframes=1
//#exec meshmap new meshmap="aerbullet" mesh="aerbullet"
//#exec meshmap scale meshmap="aerbullet" x=0.04379 y=0.04379 z=0.08759

//#exec mesh import mesh="aerbullet2" anivfile="Models\aerbullet2_a.3d" datafile="Models\aerbullet2_d.3d" x=0 y=0 z=0 mlod=0
//#exec mesh origin mesh="aerbullet2" x=0 y=0 z=0
//#exec mesh sequence mesh="aerbullet2" seq=All startframe=0 numframes=1
//#exec meshmap new meshmap="aerbullet2" mesh="aerbullet2"
//#exec meshmap scale meshmap="aerbullet2" x=0.03128 y=0.03128 z=0.06256


var byte        deaim_rate;
var int         debugscore;
var int         child_wait,
                trail_count,
                fire_power,
                penetrability,             // for wall pass
                maxpenetrability;          // for dmg effect
var sound       soundwall[8],soundflesh[8];
var actor       init_targ;
var float       sound_rnd_seed;
var int         sound_rnd_sel;
var int         accumulated_damage;
var bool        accumulated_dead,accumulated_carc;
var vector      prev_location,fire_location;
var aerwpn      w;
var bool        higher_ionize;
var bool        DisableHitsens;
//var bool        stop_effects;              // upd 15.01.24 - light is shit, removed. maybe unlit tracer mesh.

var vector initial_dir,target_spot;    // initial direction
var float  move_vel;                   // tracking calcs

// function timer(){
//    local vector start_dir;
//    start_dir = normal(target_spot - location) * 1.0;
//    if((start_dir dot initial_dir) <= 0) return;
//    move_vel = vsize(vector(rotation) * speed);
//    velocity = move_vel * normal(start_dir * move_vel + velocity);             
//    setrotation(rotator(velocity));
// }

function postbeginplay(){
//   local rotator r;
   prev_location = location;
   fire_location = location;
//   r = self.rotation;
//   r.roll = frand() * 65536;
//   self.setrotation(r);
}

function do_ionize(){
   local AerGr_trail_bullet atb;
   local byte i;
   local int j;
   local vector hl,hn,x,y,z;
  return;
   getaxes(rotation,x,y,z);
   trace(hl, hn, location + 10000*x, location, false);
   j = vsize(location - hl) / 96.0;
   if(j > 64) j = 64;
   for(i=0;i<j;i++){
      atb = spawn(class'AerGr_trail_bullet',,,location + 96.0*x*i);   // was deleted, eats GPU on this fire rate.
      if(atb == none) continue;
      if(higher_ionize){
         atb.i = 55;
         atb.LightRadius = 7;
      }
   }
}

function tick(float f){
//   local bool b4th_trail;
//   local float deaim_calc;
//   local rotator r;
//   local int tmp_count;
//   tmp_count = trail_count >> 2;
//   tmp_count = tmp_count   << 2;
//   b4th_trail = tmp_count == trail_count;

   if(vsizesq(prev_location-location) >= 16384){  // each 256uu, was 16
      trail_count++;
      prev_location = location;                                                 // todo move this to weapon, use rotator
 /*     r = rotation;
      deaim_calc = deaim_rate;
      r.yaw   += (FRand() * deaim_calc * 2) - deaim_calc;     
      r.pitch += (FRand() * deaim_calc * 2) - deaim_calc;   
      setrotation(r);
      if(speed >= 25000) return;
      speed = default.speed + (trail_count * 80.0);  // was 160
//      broadcastmessage(speed);
      velocity = vector(r) * speed;                            */

//      if(trail_count >= 2 && self.DrawType == DT_None) self.DrawType = DT_Mesh;

//      if(LightBrightness < 210) LightBrightness = clamp(trail_count,1,210) * 6;

//    if(trail_count > 4 && allowtrails && !region.zone.bwaterzone) t = spawn(class'AerGr_trail_bullet'); // todo remove
//    if(region.zone.bwaterzone) spawn(class'aerbubble');

//      if(DrawScale>=1.2) return;
//      DrawScale *= 1.2;            // increase mesh   // deleted, removed mesh
   }
}

function actor finddbgactor(){
  local actor a;
  foreach allactors(class'actor',a) if(a.isa('trigger')) return a;
  return none;
}
state Launch{
Begin:
   Sleep(child_wait * (0.014 / level.timedilation));       // flying state, from tentacleproj code. todo: why .014?
   initial_dir = vector(rotation);
   velocity = initial_dir * speed;
   settimer(0.01,true);
}

function AERplayExplodeSound(){
//   local aerffieldblk fwall;
// foreach radiusactors(class'aerffieldblk',fwall,40) stop_effects = true;
// if(stop_effects) return;                  // 2024-12-16: stopeffects on ffield removed, illogical
   sound_rnd_seed = frand();
   sound_rnd_sel=6;
   if(sound_rnd_seed>0.142) sound_rnd_sel = 5;
   if(sound_rnd_seed>0.284) sound_rnd_sel = 4;
   if(sound_rnd_seed>0.426) sound_rnd_sel = 3;
   if(sound_rnd_seed>0.568) sound_rnd_sel = 2;
   if(sound_rnd_seed>0.710) sound_rnd_sel = 1;
   if(sound_rnd_seed>0.852) sound_rnd_sel = 0;
   playsound(soundwall[sound_rnd_sel],SLOT_None,32,,1200); // was 400
}

function AERplayFleshSound(/*actor o*/){
   sound_rnd_seed = frand();
   sound_rnd_sel=4;
   if(sound_rnd_seed>0.225) sound_rnd_sel = 3;
   if(sound_rnd_seed>0.450) sound_rnd_sel = 2;
   if(sound_rnd_seed>0.675) sound_rnd_sel = 1;
   if(sound_rnd_seed>0.800) sound_rnd_sel = 0;
   playsound(soundflesh[sound_rnd_sel],SLOT_Misc,128,,4200);
}
function AERSpawnSparks(vector hitloc,vector hitnor){
   local effects s;
//   local aerffieldblk fwall;
// foreach radiusactors(class'aerffieldblk',fwall,40) stop_effects = true;
// if(stop_effects) return;                  // 2024-12-16: stopeffects on ffield removed, illogical
   spawn(class'pock',,,hitloc + hitnor, Rotator(hitnor));
   if(region.zone.bwaterzone) return;
   s = spawn(class'smallspark2',,,hitloc + hitnor * 5, rotator(hitnor * 2 + VRand()));
   if(s != none) s.RemoteRole = ROLE_None;
//   if(rotator(hitnor).pitch > 0) return; // detect ceiling
// s = spawn(class'ut_sparks',,,hitloc + hitnor * 5, rotator(hitnor * 2 + VRand()));
// if(s == none) return;
// s.drawscale /= 2;
// s.RemoteRole = ROLE_None;
}

function AERFleshEffects(actor other, vector hitloc, vector momentum){
//   local effects e;  // todo check HER and how to replace if UT
   local AerGr_afterglow ag;
   local vector v, mo;
   local byte k;
   local rotator splatRotator;
   local aerprjbloodspurt bs;
   splatRotator.pitch=16384;
   AERplayFleshSound();
   init_targ = other;
   bs = spawn(class'aerprjbloodspurt');
   if(bs != none) bs.init_targ = init_targ;
// e = spawn(class'UT_BigBloodHit',,,hitloc);
// e.drawscale = 0.02;
   for(k = 0; k < 3; k++){
      v = hitloc;
      v.x += 5 * FRand();
      v.x -= 7 * FRand();
      v.y += 5 * FRand();
      v.y -= 7 * FRand();
      v.z += 5 * FRand();
      v.z -= 7 * FRand();
      spawn(class'BloodBurst',,,v);
   }
   mo = momentum;                    // from moregore code
   if(mo.z > 0) mo.z *= 0.9;
   spawn(class'BloodSplat',,, other.Location, splatRotator);
   for (k=1; k<3; k++) spawn(class'BloodSpray',,,HitLoc, rotator(mo));
   ag = spawn(class'AerGr_afterglow');
   if(ag != none) ag.LightBrightness = self.LightBrightness;
}

function Explode(vector HitLocation,vector HitNormal){
//   local effects s; todo check in H.E.R. why this
   local AerGr_afterglow ag;
   local int full_penetrability;
   local aerffieldblk fwall;
   local aerblooddrop b;
   local int j, accdmg_tmp;
   local aerprjhurtdmg m; //,mr;
   local vector x,y,z,sw;
   local bool hitflesh;
   local bool hitffield;
   local bool did_penmon_write;
   local actor atarg;
   local string traceactor_grp;
// local vector hitloc_u,hitnor_u; // unused, for hitactor retrace
   GetAxes(Rotation,X,Y,Z);
   foreach radiusactors(class'aerffieldblk',fwall,40) hitffield = true;
// atarg = Trace(hitloc_u,hitnor_u, hitlocation + 24*x, hitlocation - 16*x,True);  // trace -16 from hitloc again to obtain actor
   TraceSurfHitInfo(hitlocation-16*x,hitlocation+24*x,,,,j,,atarg);  // shit name bu we clean this var later
   did_penmon_write = false;
   traceactor_grp = caps(string(atarg.group));
   if(((j & PF_FakeBackdrop) != 0) || atarg.isa('aerlaserdistractor') ||
     (instr(traceactor_grp,"AERLASERDISTRACTOR") != -1) ) did_penmon_write = true;
   if(traceactor_grp == "AERBLOCK") hitffield = true;                   // prohibit chainspawn if requested
   if(traceactor_grp == "AERTBLOCK") hitffield = true;
   hitflesh = init_targ != none;
   j = 0;
   full_penetrability = penetrability;
   if(hitffield) goto skip_ffield_chainspawn;
   while(penetrability > 0){
      j += 1;
      if(penetrability >= 2) penetrability-=2; else penetrability = 0;
      sw = HitLocation + HitNormal + x * 32 * j;
      m = spawn(self.class,,,sw);
      if(m == none){
         accdmg_tmp = accumulated_damage;
         if(accdmg_tmp < 0)   accdmg_tmp = 800;
         if(accumulated_dead) accdmg_tmp = 800;          // 40 = dead flag
         if(accumulated_carc) accdmg_tmp = 1000;         // 50 = corpse flag
         accdmg_tmp *= 0.05;  // faster than /= 20
         if(hitflesh && accdmg_tmp == 0) accdmg_tmp = 1;
         if(w != none) w.do_dmgmon_write(accdmg_tmp);
         continue;
      }
/*      if(!stop_effects && group == 'AERmuzzleproj') mr = spawn(class'aerprjrev',,,sw); // hit target camping close to outwall
      if(mr!=none){
         mr.w = self.w;                               // inherit weapon
         mr.stop_effects = self.stop_effects;
         mr.fire_location = self.fire_location;
         mr.gotostate('Launch');
      } */
      m.w = self.w;
      m.fire_location = self.fire_location;
      m.child_wait = j;                               // setup child
      m.penetrability    = self.penetrability;
      m.maxpenetrability = self.maxpenetrability;
      m.fire_location    = self.fire_location;
      m.speed            = self.speed;
      m.DrawScale        = self.DrawScale;
      m.trail_count      = self.trail_count;
      m.fire_power       = self.fire_power;
      m.gotostate('Launch');
      if(w != none && group == 'AERmuzzleproj'){
         w.do_penmon_write(penetrability,full_penetrability);
         did_penmon_write = true;
      }
      break;
   }
   skip_ffield_chainspawn:
   if(w != none && group == 'AERmuzzleproj' && !did_penmon_write) w.do_penmon_write(0,full_penetrability);
//   if(stop_effects && !hitffield) destroy();
   AERplayExplodeSound();
   AERSpawnSparks(HitLocation,HitNormal);
   for(j=0;j<rand(6)+1;j++){
      if(hitflesh) b = spawn(class'aerblooddrop');
      if(b == none) break;
      b.initfor(init_targ);
      if(j<3) b.velocity = vector(rotation) * (default.speed/4); // todo regain speed
   }
   makenoise(1.0);
   ag = spawn(class'AerGr_afterglow');
   if(ag != none) ag.LightBrightness = self.LightBrightness;
   destroy();
}

function AERHurtSpawn(pawn p){
   local aerhurt ah;
   ah = spawn(class'aerhurt',,,vect(65535,65535,65535));
   if(ah == none) return;
   ah.becomeitem();
   ah.instigator = instigator;
   p.addinventory(ah);
}

function ProcessTouch(actor other, vector hitlocation){   // todo
   local bool ignorestuff,stationary;  // know_future next_traced_actor. maybe give a sense
   local float shot_dist;              //  about what we hit next and adjust decisions (effects, penetrability)
   const mom_incr = 2.5;
   const mom_incr_stby = 1.4;
   local byte dmg_base;
   local aerhurt ah;
   local pawn p;
   local byte i;
   local string traceactor_grp;
   p = pawn(other);
   if(other == instigator) return;
   traceactor_grp = caps(string(other.group));
   if( (instr(traceactor_grp,"AERBLOCK") != -1) ||       // todo confirm whether this working
       (instr(traceactor_grp,"AERTBLOCK") != -1) ){
         penetrability = 0;
         maxpenetrability = 0;
   }
   damage = default.damage;
   // ----------------------------------------- generic decisions --------------------------------------------------
   if(bool(aergr_ffield(other)) || bool(aerffieldblk(other))) return;
   if(bool(projectile(other))) projectile(other).explode(other.location,normal(other.location));
   ignorestuff = other.bispawn || bool(triggers(other)) || bool(aercfgkey(other)) || bool(creaturecarcass(other));
   if(!ignorestuff){
      sound_rnd_seed = frand();
      if(sound_rnd_seed > 0.4) playsound(sound'aerstuff1',SLOT_None,16,,600);
      other.playsound(sound'aerstuff2',SLOT_None,16,,600);
   }
   if(!other.bispawn) other.takeDamage(5, instigator, hitlocation, MomentumTransfer*Normal(Velocity), 'shot');
   if(p == none){
      if(bool(creaturecarcass(other))){
         if(!accumulated_carc) accumulated_carc = true;
         AERplayFleshSound();
      }
      return;
   }
//   p.Destination = p.Location + 120 * Normal(p.Location - hitlocation);    // force pawns to fear bullets.
                                                                             // deleted but they keep doing that tho, check wtf
   ah = none;
   stationary = other.isa('stationarypawn');
   if(stationary) goto skip_hitcannon;
   if(self.class == class'aerprjhurtdmg') AERFleshEffects(other, hitlocation, MomentumTransfer*Normal(Velocity));
   ah = aerhurt(p.findinventorytype(class'aerhurt'));
   if(ah == none) AERHurtSpawn(p);
   skip_hitcannon:
   // ----------------------------------------- unable to spawn pain, override unattended --------------------------
   shot_dist = vsize(hitlocation - fire_location);     // cancer naming, this var used for hit.z control
   dmg_base = 12;
   if(shot_dist > 1024){
      shot_dist -= 1024;
      dmg_base += clamp(shot_dist*0.005376,1,8); //+1 more dmg each 186 dist, 20 max
   }
   if(ah==none){
      if(p.enemy==none)  // safe to use 'p'
        other.takeDamage(5, instigator, hitlocation, MomentumTransfer*Normal(Velocity)*mom_incr_stby, 'shot'); // step1: dmg
      else
        other.takeDamage(5, instigator, hitlocation, MomentumTransfer*Normal(Velocity)*mom_incr,      'shot');
   }else
      damage = clamp(ah.holes,1,50) * dmg_base;  // speeds up in 50 shots, no dist effect, 1000 max

   if(p.collisionheight<15.0 && p.collisionradius<30.0)
      other.takeDamage(35, instigator, hitlocation, vect(0,0,0), 'shot'); // suredamage nasty smallpawns

   if(stationary) return;
   if(w != none && !DisableHitsens && instigator != none)
     for(i=0; i<w.radar_qty; i++) if(w.radar[i].t == other.name) w.radar[i].hit = true;   // step2: hitsens (always)
   if(w != none) w.attempt_tag_target(p);                               // step3: tag target (always)
   if(ah == none) return;                                   // terminate (spawn pain failed ends)
   // --------------------------------------------------------------------------------------------------------------
   if(p.health<damage){                                     // this exec only if successfully found aerhurt
      if(!accumulated_dead) accumulated_dead = true;
      damage = p.health + 5;
      if(damage<0) damage = 5;
      other.group = '';
      if(!accumulated_dead && (level.timeseconds-ah.lasthit_timer>=0.4))
         MomentumTransfer *= 4.0;
      else MomentumTransfer *= 0.02;
   }
   other.takeDamage(5, instigator, hitlocation, MomentumTransfer*Normal(Velocity), 'shot'); // to make momentum working
   ah.pending_damage += damage;
   accumulated_damage += damage;
   if(!accumulated_dead && bool(creaturecarcass(other))) accumulated_dead = true;
   ah.addholes();
}

defaultproperties{
        ambientglow=128
        deaim_rate=1
        child_wait=0
        trail_count=1
        fire_power=1
        penetrability=1
        maxpenetrability=1
        accumulated_damage=0
        accumulated_dead=false
        sound_rnd_sel=0
        sound_rnd_seed=0.0
        soundwall(0)=Sound'AER.Sound.aerwall1'
        soundwall(1)=Sound'AER.Sound.aerwall2'
        soundwall(2)=Sound'AER.Sound.aerwall3'
        soundwall(3)=Sound'AER.Sound.aerwall4'
        soundwall(4)=Sound'AER.Sound.aerwall5'
        soundwall(5)=Sound'AER.Sound.aerwall6'
        soundwall(6)=Sound'AER.Sound.aerwall7'
        soundwall(7)=None
        soundflesh(0)=Sound'AER.Sound.aerflesh1'
        soundflesh(1)=Sound'AER.Sound.aerflesh2'
        soundflesh(2)=Sound'AER.Sound.aerflesh3'
        soundflesh(3)=Sound'AER.Sound.aerflesh4'
        soundflesh(4)=Sound'AER.Sound.aerflesh5'
        init_targ=None
        w=None
        higher_ionize=false
        prev_location=(X=0.0,Y=0.0,Z=0.0)
        fire_location=(X=0.0,Y=0.0,Z=0.0)
        DisableHitsens=False
        MomentumTransfer=15000
        speed=22000.0
//      speed=12200 270m/s
//      speed=40000.0
//      speed=26000.0 latest
        MaxSpeed=22000.0
//      MaxSpeed=48000.0
        Damage=5.0
//        DrawType=DT_Mesh
        DrawType=DT_None
        DrawScale=0.7
//        Mesh=Mesh'aerbullet3'
//        Mesh=Mesh'AER.aerlaserblast'
//        MultiSkins(0)=Texture'aertracer'
//        MultiSkins(0)=Texture'aerscreenbg'
        ScaleGlow=3.00000
        LightEffect=LE_NonIncidence
        LightType=LT_None
//        LightType=LT_Steady
        LightBrightness=5
        LightHue=170
        LightSaturation=195
        LightRadius=6
}
