class AerGr_ffield extends effects;
// bug: same behavior as laser, zonevelocitied areas cause unwanted FField speed, while BlockAlls stay in place
// (on foundry, visible field may float away from owner, if plant on conveyor)
#exec obj load file="..\System\Unrealshare.u" package="Unrealshare"
#exec texture import file="textures\skin\aerfield2.png" name="aerfield" package="AER" group="Skin" mips=1 flags=0 btc=-2

#exec mesh import mesh="aerfieldblast01" anivfile="models_ff\aerfieldblast01_a.3d" datafile="models_ff\aerfieldblast01_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast01" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast01" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast01" mesh="aerfieldblast01"
#exec meshmap scale meshmap="aerfieldblast01" x=0.25498 y=0.25498 z=0.50997
#exec mesh import mesh="aerfieldblast02" anivfile="models_ff\aerfieldblast02_a.3d" datafile="models_ff\aerfieldblast02_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast02" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast02" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast02" mesh="aerfieldblast02"
#exec meshmap scale meshmap="aerfieldblast02" x=0.25453 y=0.25453 z=0.50906
#exec mesh import mesh="aerfieldblast03" anivfile="models_ff\aerfieldblast03_a.3d" datafile="models_ff\aerfieldblast03_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast03" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast03" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast03" mesh="aerfieldblast03"
#exec meshmap scale meshmap="aerfieldblast03" x=0.25415 y=0.25415 z=0.50830
#exec mesh import mesh="aerfieldblast04" anivfile="models_ff\aerfieldblast04_a.3d" datafile="models_ff\aerfieldblast04_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast04" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast04" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast04" mesh="aerfieldblast04"
#exec meshmap scale meshmap="aerfieldblast04" x=0.25347 y=0.25347 z=0.50694
#exec mesh import mesh="aerfieldblast05" anivfile="models_ff\aerfieldblast05_a.3d" datafile="models_ff\aerfieldblast05_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast05" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast05" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast05" mesh="aerfieldblast05"
#exec meshmap scale meshmap="aerfieldblast05" x=0.25279 y=0.25279 z=0.50559
#exec mesh import mesh="aerfieldblast06" anivfile="models_ff\aerfieldblast06_a.3d" datafile="models_ff\aerfieldblast06_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast06" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast06" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast06" mesh="aerfieldblast06"
#exec meshmap scale meshmap="aerfieldblast06" x=0.25217 y=0.25217 z=0.50435
#exec mesh import mesh="aerfieldblast07" anivfile="models_ff\aerfieldblast07_a.3d" datafile="models_ff\aerfieldblast07_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast07" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast07" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast07" mesh="aerfieldblast07"
#exec meshmap scale meshmap="aerfieldblast07" x=0.25172 y=0.25172 z=0.50344
#exec mesh import mesh="aerfieldblast08" anivfile="models_ff\aerfieldblast08_a.3d" datafile="models_ff\aerfieldblast08_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast08" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast08" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast08" mesh="aerfieldblast08"
#exec meshmap scale meshmap="aerfieldblast08" x=0.25092 y=0.25092 z=0.50184
#exec mesh import mesh="aerfieldblast09" anivfile="models_ff\aerfieldblast09_a.3d" datafile="models_ff\aerfieldblast09_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast09" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast09" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast09" mesh="aerfieldblast09"
#exec meshmap scale meshmap="aerfieldblast09" x=0.25044 y=0.25044 z=0.50088
#exec mesh import mesh="aerfieldblast10" anivfile="models_ff\aerfieldblast10_a.3d" datafile="models_ff\aerfieldblast10_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast10" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast10" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast10" mesh="aerfieldblast10"
#exec meshmap scale meshmap="aerfieldblast10" x=0.25090 y=0.25090 z=0.50180
#exec mesh import mesh="aerfieldblast11" anivfile="models_ff\aerfieldblast11_a.3d" datafile="models_ff\aerfieldblast11_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast11" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast11" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast11" mesh="aerfieldblast11"
#exec meshmap scale meshmap="aerfieldblast11" x=0.25104 y=0.25104 z=0.50209
#exec mesh import mesh="aerfieldblast12" anivfile="models_ff\aerfieldblast12_a.3d" datafile="models_ff\aerfieldblast12_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast12" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast12" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast12" mesh="aerfieldblast12"
#exec meshmap scale meshmap="aerfieldblast12" x=0.25031 y=0.25031 z=0.50063
#exec mesh import mesh="aerfieldblast13" anivfile="models_ff\aerfieldblast13_a.3d" datafile="models_ff\aerfieldblast13_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast13" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast13" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast13" mesh="aerfieldblast13"
#exec meshmap scale meshmap="aerfieldblast13" x=0.25025 y=0.25025 z=0.50049
#exec mesh import mesh="aerfieldblast14" anivfile="models_ff\aerfieldblast14_a.3d" datafile="models_ff\aerfieldblast14_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast14" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast14" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast14" mesh="aerfieldblast14"
#exec meshmap scale meshmap="aerfieldblast14" x=0.24929 y=0.24929 z=0.49858
#exec mesh import mesh="aerfieldblast15" anivfile="models_ff\aerfieldblast15_a.3d" datafile="models_ff\aerfieldblast15_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast15" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast15" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast15" mesh="aerfieldblast15"
#exec meshmap scale meshmap="aerfieldblast15" x=0.24823 y=0.24823 z=0.49645
#exec mesh import mesh="aerfieldblast16" anivfile="models_ff\aerfieldblast16_a.3d" datafile="models_ff\aerfieldblast16_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast16" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast16" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast16" mesh="aerfieldblast16"
#exec meshmap scale meshmap="aerfieldblast16" x=0.24800 y=0.24800 z=0.49599
#exec mesh import mesh="aerfieldblast17" anivfile="models_ff\aerfieldblast17_a.3d" datafile="models_ff\aerfieldblast17_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast17" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast17" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast17" mesh="aerfieldblast17"
#exec meshmap scale meshmap="aerfieldblast17" x=0.24794 y=0.24794 z=0.49588
#exec mesh import mesh="aerfieldblast18" anivfile="models_ff\aerfieldblast18_a.3d" datafile="models_ff\aerfieldblast18_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast18" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast18" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast18" mesh="aerfieldblast18"
#exec meshmap scale meshmap="aerfieldblast18" x=0.24752 y=0.24752 z=0.49505
#exec mesh import mesh="aerfieldblast19" anivfile="models_ff\aerfieldblast19_a.3d" datafile="models_ff\aerfieldblast19_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast19" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast19" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast19" mesh="aerfieldblast19"
#exec meshmap scale meshmap="aerfieldblast19" x=0.24700 y=0.24700 z=0.49400
#exec mesh import mesh="aerfieldblast20" anivfile="models_ff\aerfieldblast20_a.3d" datafile="models_ff\aerfieldblast20_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast20" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast20" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast20" mesh="aerfieldblast20"
#exec meshmap scale meshmap="aerfieldblast20" x=0.24650 y=0.24650 z=0.49300
#exec mesh import mesh="aerfieldblast21" anivfile="models_ff\aerfieldblast21_a.3d" datafile="models_ff\aerfieldblast21_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast21" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast21" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast21" mesh="aerfieldblast21"
#exec meshmap scale meshmap="aerfieldblast21" x=0.24621 y=0.24621 z=0.49243
#exec mesh import mesh="aerfieldblast22" anivfile="models_ff\aerfieldblast22_a.3d" datafile="models_ff\aerfieldblast22_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast22" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast22" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast22" mesh="aerfieldblast22"
#exec meshmap scale meshmap="aerfieldblast22" x=0.24459 y=0.24459 z=0.48918
#exec mesh import mesh="aerfieldblast23" anivfile="models_ff\aerfieldblast23_a.3d" datafile="models_ff\aerfieldblast23_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast23" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast23" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast23" mesh="aerfieldblast23"
#exec meshmap scale meshmap="aerfieldblast23" x=0.24194 y=0.24194 z=0.48388
#exec mesh import mesh="aerfieldblast24" anivfile="models_ff\aerfieldblast24_a.3d" datafile="models_ff\aerfieldblast24_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast24" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast24" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast24" mesh="aerfieldblast24"
#exec meshmap scale meshmap="aerfieldblast24" x=0.24169 y=0.24169 z=0.48338
#exec mesh import mesh="aerfieldblast25" anivfile="models_ff\aerfieldblast25_a.3d" datafile="models_ff\aerfieldblast25_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast25" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast25" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast25" mesh="aerfieldblast25"
#exec meshmap scale meshmap="aerfieldblast25" x=0.24101 y=0.24101 z=0.48201
#exec mesh import mesh="aerfieldblast26" anivfile="models_ff\aerfieldblast26_a.3d" datafile="models_ff\aerfieldblast26_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast26" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast26" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast26" mesh="aerfieldblast26"
#exec meshmap scale meshmap="aerfieldblast26" x=0.24040 y=0.24040 z=0.48080
#exec mesh import mesh="aerfieldblast27" anivfile="models_ff\aerfieldblast27_a.3d" datafile="models_ff\aerfieldblast27_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast27" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast27" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast27" mesh="aerfieldblast27"
#exec meshmap scale meshmap="aerfieldblast27" x=0.23966 y=0.23966 z=0.47932
#exec mesh import mesh="aerfieldblast28" anivfile="models_ff\aerfieldblast28_a.3d" datafile="models_ff\aerfieldblast28_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast28" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast28" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast28" mesh="aerfieldblast28"
#exec meshmap scale meshmap="aerfieldblast28" x=0.23920 y=0.23920 z=0.47840
#exec mesh import mesh="aerfieldblast29" anivfile="models_ff\aerfieldblast29_a.3d" datafile="models_ff\aerfieldblast29_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast29" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast29" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast29" mesh="aerfieldblast29"
#exec meshmap scale meshmap="aerfieldblast29" x=0.23892 y=0.23892 z=0.47785
#exec mesh import mesh="aerfieldblast30" anivfile="models_ff\aerfieldblast30_a.3d" datafile="models_ff\aerfieldblast30_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast30" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast30" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast30" mesh="aerfieldblast30"
#exec meshmap scale meshmap="aerfieldblast30" x=0.23937 y=0.23937 z=0.47874
#exec mesh import mesh="aerfieldblast31" anivfile="models_ff\aerfieldblast31_a.3d" datafile="models_ff\aerfieldblast31_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast31" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast31" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast31" mesh="aerfieldblast31"
#exec meshmap scale meshmap="aerfieldblast31" x=0.24026 y=0.24026 z=0.48052
#exec mesh import mesh="aerfieldblast32" anivfile="models_ff\aerfieldblast32_a.3d" datafile="models_ff\aerfieldblast32_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast32" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast32" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast32" mesh="aerfieldblast32"
#exec meshmap scale meshmap="aerfieldblast32" x=0.23807 y=0.23807 z=0.47615
#exec mesh import mesh="aerfieldblast33" anivfile="models_ff\aerfieldblast33_a.3d" datafile="models_ff\aerfieldblast33_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast33" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast33" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast33" mesh="aerfieldblast33"
#exec meshmap scale meshmap="aerfieldblast33" x=0.23903 y=0.23903 z=0.47807
#exec mesh import mesh="aerfieldblast35" anivfile="models_ff\aerfieldblast35_a.3d" datafile="models_ff\aerfieldblast35_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast35" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast35" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast35" mesh="aerfieldblast35"
#exec meshmap scale meshmap="aerfieldblast35" x=0.24142 y=0.24142 z=0.48284
#exec mesh import mesh="aerfieldblast36" anivfile="models_ff\aerfieldblast36_a.3d" datafile="models_ff\aerfieldblast36_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast36" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast36" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast36" mesh="aerfieldblast36"
#exec meshmap scale meshmap="aerfieldblast36" x=0.24152 y=0.24152 z=0.48304
#exec mesh import mesh="aerfieldblast37" anivfile="models_ff\aerfieldblast37_a.3d" datafile="models_ff\aerfieldblast37_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast37" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast37" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast37" mesh="aerfieldblast37"
#exec meshmap scale meshmap="aerfieldblast37" x=0.24331 y=0.24331 z=0.48662
#exec mesh import mesh="aerfieldblast38" anivfile="models_ff\aerfieldblast38_a.3d" datafile="models_ff\aerfieldblast38_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast38" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast38" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast38" mesh="aerfieldblast38"
#exec meshmap scale meshmap="aerfieldblast38" x=0.24479 y=0.24479 z=0.48957
#exec mesh import mesh="aerfieldblast39" anivfile="models_ff\aerfieldblast39_a.3d" datafile="models_ff\aerfieldblast39_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast39" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast39" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast39" mesh="aerfieldblast39"
#exec meshmap scale meshmap="aerfieldblast39" x=0.24674 y=0.24674 z=0.49347
#exec mesh import mesh="aerfieldblast40" anivfile="models_ff\aerfieldblast40_a.3d" datafile="models_ff\aerfieldblast40_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast40" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast40" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast40" mesh="aerfieldblast40"
#exec meshmap scale meshmap="aerfieldblast40" x=0.24812 y=0.24812 z=0.49625
#exec mesh import mesh="aerfieldblast41" anivfile="models_ff\aerfieldblast41_a.3d" datafile="models_ff\aerfieldblast41_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerfieldblast41" x=0 y=0 z=0
#exec mesh sequence mesh="aerfieldblast41" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerfieldblast41" mesh="aerfieldblast41"
#exec meshmap scale meshmap="aerfieldblast41" x=0.25086 y=0.25086 z=0.50171

var mesh meshframe[40];
var bool proj_reactive;
var float openwall_timer,delayed_zonevel_leash_timer;
var bool ena_openwall;
var AerWk_FFR openwall_reactor;
var float last_anim,last_anim_dep;
var byte mframe; // still
var byte sframe; // deploy/collapse
var bool ena_collapse;
var bool nf_dir; // true=fwd
var aerffieldblk field_wall[16];
var byte ena_wall;
var float field_w,field_h;
var byte field_consume_level;
var actor field_hull;
var bool deploy_done;
var vector initial_location;

function tick(float f){
   local byte i;
   if(delayed_zonevel_leash_timer > 0.0){
      delayed_zonevel_leash_timer -= f;
      if(delayed_zonevel_leash_timer <= 0.0){
         velocity = vect(0,0,0);
         setlocation(initial_location);
      }
   }
   if(ena_openwall){
      if(openwall_timer > 0.0) openwall_timer -= f;
       else reactive_close_wall();
   }
   if(sframe<100) animdeploy();
   if(sframe>=100 && !deploy_done){
      if(field_hull != none) field_hull.group = 'AERoccupied';
      deploy_done = true;
//    for(i=0;i<16;i++) field_wall[i].group='AERBLOCK';
      if(proj_reactive){
         openwall_reactor = spawn(class'AerWk_FFR');
         if(openwall_reactor!=none) openwall_reactor.field_targ = self;
      }
   }
   if(sframe<200 && ena_collapse) animcollapse();
   if(sframe>=200){
      if(instigator != none) instigator.PlaySound(Sound'UnrealShare.Pickups.FSHLITE2');
      for(i=0;i<16;i++) if(field_wall[i] != none) field_wall[i].destroy();
      if(field_hull != none) field_hull.group = '';
      if(openwall_reactor!=none) openwall_reactor.destroy();
      destroy();
   }
   if(level.timeseconds - last_anim < 0.065) return;
   last_anim = level.timeseconds;
   mesh = meshframe[mframe];
   if(nf_dir) mframe++;
     else mframe--;
   if(mframe == 0 || mframe == 39) nf_dir = !nf_dir;
}

function animdeploy(){
   if(level.timeseconds - last_anim_dep < 0.012) return;  // was .008
   if(proj_reactive && MultiSkins[0] != FireTexture'UnrealShare.Belt_fx.BlueShield')
      MultiSkins[0] = FireTexture'UnrealShare.Belt_fx.BlueShield';
   last_anim_dep = level.timeseconds;
   sframe++;
   if(sframe % 12 == 0){
      if(field_wall[7-ena_wall] != none){
         field_wall[7-ena_wall].setCollision(true,true,true);
         field_wall[7-ena_wall].bProjTarget=true;
       }
      if(field_wall[8+ena_wall] != none){
         field_wall[8+ena_wall].setCollision(true,true,true);
         field_wall[8+ena_wall].bProjTarget=true;
      }
      ena_wall++;
   }
   LightBrightness    = 2*sframe;
   LightRadius        = 2*(sframe/10);
   DrawScale3D.x = 0.0035*sframe;
   DrawScale3D.y = 0.0150*sframe*(field_w/384);
   DrawScale3D.z = 0.0075*sframe*(field_h/192);
}

function animcollapse(){
   if(level.timeseconds - last_anim_dep < 0.004) return;
   last_anim_dep = level.timeseconds;
   sframe++;
   if((sframe-100) % 12 == 0){
      if(field_wall[7-ena_wall] != none){
         field_wall[7-ena_wall].setCollision(false,false,false);
         field_wall[7-ena_wall].bProjTarget=false;
       }
      if(field_wall[8+ena_wall] != none){
         field_wall[8+ena_wall].setCollision(false,false,false);
         field_wall[8+ena_wall].bProjTarget=false;
      }
      ena_wall--;
   }
   LightBrightness    = 200 - 2*(sframe-100);
   LightRadius        = 20  - 2*((sframe-100)/10);
   DrawScale3D.x =  0.35                - (0.0035*(sframe-100));
   DrawScale3D.y = (1.50*(field_w/384)) - (0.0150*(sframe-100)*(field_w/384));
   DrawScale3D.z = (0.75*(field_h/192)) - (0.0075*(sframe-100)*(field_h/192));
}

function postbeginplay(){
   local byte i;
   local vector x,y,z;
   getaxes(rotation,x,y,z);
   initial_location = location;
   for(i=0;i<16;i++) field_wall[i] = spawn(class'aerffieldblk',,,location-y*180+y*(24*i));
}

function reactive_open_wall(){
   local byte i;
   for(i=0;i<16;i++) field_wall[i].setCollision(false,false,false);
   MultiSkins[0] = FireTexture'UnrealShare.Belt_fx.GreenShield';
   openwall_timer = 0.2;
   ena_openwall = true;
}

function reactive_close_wall(){
   local byte i;
   for(i=0;i<16;i++) field_wall[i].setCollision(true,true,true);
   MultiSkins[0] = FireTexture'UnrealShare.Belt_fx.BlueShield';
   ena_openwall = false;
}

singular function zonechange(zoneinfo nz){
   super.zonechange(nz);
   if(vsizesq(velocity) > 0) delayed_zonevel_leash_timer = 0.15;
}

defaultproperties{
        last_anim=0.0
        last_anim_dep=0.0
        field_w=384.0
        field_h=192.0
        meshframe(0)=Mesh'AER.aerfieldblast01'
        meshframe(1)=Mesh'AER.aerfieldblast02'
        meshframe(2)=Mesh'AER.aerfieldblast03'
        meshframe(3)=Mesh'AER.aerfieldblast04'
        meshframe(4)=Mesh'AER.aerfieldblast05'
        meshframe(5)=Mesh'AER.aerfieldblast06'
        meshframe(6)=Mesh'AER.aerfieldblast07'
        meshframe(7)=Mesh'AER.aerfieldblast08'
        meshframe(8)=Mesh'AER.aerfieldblast09'
        meshframe(9)=Mesh'AER.aerfieldblast10'
        meshframe(10)=Mesh'AER.aerfieldblast11'
        meshframe(11)=Mesh'AER.aerfieldblast12'
        meshframe(12)=Mesh'AER.aerfieldblast13'
        meshframe(13)=Mesh'AER.aerfieldblast14'
        meshframe(14)=Mesh'AER.aerfieldblast15'
        meshframe(15)=Mesh'AER.aerfieldblast16'
        meshframe(16)=Mesh'AER.aerfieldblast17'
        meshframe(17)=Mesh'AER.aerfieldblast18'
        meshframe(18)=Mesh'AER.aerfieldblast19'
        meshframe(19)=Mesh'AER.aerfieldblast20'
        meshframe(20)=Mesh'AER.aerfieldblast21'
        meshframe(21)=Mesh'AER.aerfieldblast22'
        meshframe(22)=Mesh'AER.aerfieldblast23'
        meshframe(23)=Mesh'AER.aerfieldblast24'
        meshframe(24)=Mesh'AER.aerfieldblast25'
        meshframe(25)=Mesh'AER.aerfieldblast26'
        meshframe(26)=Mesh'AER.aerfieldblast27'
        meshframe(27)=Mesh'AER.aerfieldblast28'
        meshframe(28)=Mesh'AER.aerfieldblast29'
        meshframe(29)=Mesh'AER.aerfieldblast30'
        meshframe(30)=Mesh'AER.aerfieldblast31'
        meshframe(31)=Mesh'AER.aerfieldblast32'
        meshframe(32)=Mesh'AER.aerfieldblast33'
        meshframe(33)=Mesh'AER.aerfieldblast35'
        meshframe(34)=Mesh'AER.aerfieldblast36'
        meshframe(35)=Mesh'AER.aerfieldblast37'
        meshframe(36)=Mesh'AER.aerfieldblast38'
        meshframe(37)=Mesh'AER.aerfieldblast39'
        meshframe(38)=Mesh'AER.aerfieldblast40'
        meshframe(39)=Mesh'AER.aerfieldblast41'
        field_wall(0)=None
        field_wall(1)=None
        field_wall(2)=None
        field_wall(3)=None
        field_wall(4)=None
        field_wall(5)=None
        field_wall(6)=None
        field_wall(7)=None
        field_wall(8)=None
        field_wall(9)=None
        field_wall(10)=None
        field_wall(11)=None
        field_wall(12)=None
        field_wall(13)=None
        field_wall(14)=None
        field_wall(15)=None
        field_hull=None
        openwall_reactor=None
        mframe=0
        sframe=0
        ena_wall=0
        field_consume_level=1
        ena_collapse=False
        nf_dir=True
        deploy_done=False
        proj_reactive=false
        ena_openwall=false
        openwall_timer=0.0
        delayed_zonevel_leash_timer=0.0
        ScaleGlow=3.0
        CollisionRadius=1.0
        CollisionHeight=1.0
        Mesh=Mesh'AER.aerfieldblast01'
//        MultiSkins(0)=FireTexture'UnrealShare.Belt_fx.GreenShield'
        MultiSkins(0)=FireTexture'UnrealShare.Belt_fx.N_Shield'
//        MultiSkins(0)=FireTexture'UnrealShare.Belt_fx.UDamageFX'
        DrawScale3D=(X=0.0035,Y=0.01,Z=0.001)
        DrawType=DT_Mesh
        Style=STY_Translucent
        SoundRadius=128
        SoundVolume=140
        Physics=PHYS_MovingBrush
        PhysRate=9999.0
        LightType=LT_Steady
        LightEffect=LE_Shock
        LightBrightness=255
        LightHue=203
        LightSaturation=128
        LightRadius=20
}
