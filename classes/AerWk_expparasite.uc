// =============================================
// tentacle parasitic entity
// explodes when host becomes corpse
// =============================================
class AerWk_expparasite extends actor;

function postbeginplay(){
   setPhysics(PHYS_Falling);
}
function landed(vector hn){
   local byte i;
   local float rot_delta;
   local AerPj_parasite s;
   local rotator r;
   local vector l;
   r = rotation;
   l = location;
   l.z -= 12;
   rot_delta = 230;
   setPhysics(PHYS_None);
   setlocation(l);
   for(i=0;i<rand(18)+30;i++){         // todo do same, full sphere for airpush exploded corpses, no fall phys
      s = spawn(class'AerPj_parasite',,,location,r); //12+10+8+7+6+5
      r.pitch = 1000.0 + (7100.0*frand());
      if(i==12){ rot_delta = 1553.0; /* r.pitch -= (1000.0+(365.0*frand())); */}
      if(i==22){ rot_delta = 3192.0; /* r.pitch -= (1000.0+(365.0*frand())); */}
      if(i==30){ rot_delta = 4362.0; /* r.pitch -= (1000.0+(365.0*frand())); */}
      if(i==37){ rot_delta = 5922.0; /* r.pitch -= (1000.0+(365.0*frand())); */}
      if(i==43){ rot_delta = 8107.0; /* r.pitch -= (1000.0+(365.0*frand())); */ }
      r.yaw += (5000 + rot_delta + rand(rot_delta));
   }
}

defaultproperties{
   CollisionHeight=12
   CollisionRadius=8
   bHidden=true
//   drawscale=0.5
   lifespan=2.0
   bCollideWorld=true
   bCollideActors=false
   bCollideWhenPlacing=false
}