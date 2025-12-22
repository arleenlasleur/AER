class AerGr_laser extends Effects;
#exec mesh import mesh="aerlaserblast" anivfile="models\aerlaserblast_a.3d" datafile="models\aerlaserblast_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerlaserblast" x=0 y=0 z=0
#exec mesh sequence mesh="aerlaserblast" seq="All" startframe=0 numframes=1
#exec meshmap new meshmap="aerlaserblast" mesh="aerlaserblast"
#exec meshmap scale meshmap="aerlaserblast" x=0.00157 y=0.00157 z=0.00313
var float range,bearing;

function timer(){
   local bool found_aware_pawn;
//   local float bearing_diff;
   local weapon w;
//   local pawn pt,p;
   if(vsizesq(velocity) > 0) velocity = vect(0,0,0);
   found_aware_pawn = false;
   if(instigator == none) return;
   w = instigator.weapon;
   if(w == none) return;
//   if(range > 1880 || bHidden) goto skip_overrange;    // 2024-09-16: laser noise disabled
//   foreach visiblecollidingactors(class'pawn',pt,48)   // todo return this feature + see_laser timer:
//     if(caps(string(pt.group)) == "AERTARG"){        //  seelaser reset: 5 sec? accumulate: by seepawns if(bearing_diff)
//        found_aware_pawn = true;
//        p = pt;
//     }
//   if(!found_aware_pawn || p == none) goto skip_overrange;
//   bearing_diff = abs(bearing - p.rotation.yaw);
//   bearing_diff = bearing_diff % 65536;
//   if(bearing_diff>25488 || bearing_diff<40048) makenoise(1.0);
//   skip_overrange:
   if(!w.isa('aerwpn')){
     LightType = LT_None;
     bHidden = true;
   }
}

function beginplay(){
   setTimer(0.3,true);
}

singular function zonechange(zoneinfo nz){
   velocity = vect(0,0,0);
}

defaultproperties{
   range=2000.0
   ScaleGlow=3.0
   Mesh=Mesh'AER.aerlaserblast'
   MultiSkins(0)=Texture'AER.Mask.aerpixel'
   DrawType=DT_Mesh
//   LightEffect=LE_NonIncidence
//   LightBrightness=15
//   LightHue=174
//   LightSaturation=137
//   LightRadius=1
   bUnlit=True
   bNoSmooth=True
   LODBias=0.0
}
