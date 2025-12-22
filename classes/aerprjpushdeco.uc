class aerprjpushdeco extends Projectile;
var int    trail_count;
var vector prev_location;

function postbeginplay(){
   prev_location = location;
   settimer(0.01,false);
}

function timer(){
   local bool allowtrails;
   allowtrails = true;
//   if(trail_count % 4 != 0) allowtrails = false;  //former limittrailqty
   if(vsizesq(prev_location-location) >= 64){
      prev_location = location;
      trail_count++;
//    if(allowtrails && !region.zone.bwaterzone && trail_count > 3) spawn(class'AerGr_trail_air');
      // todo make water trails
   }
   if(trail_count >= 63) destroy();
   settimer(0.01,true);
}
auto state Flying{
   function BeginState(){
      settimer(0.02,true);
   }
Begin:
   velocity = vector(rotation) * speed;
}

function Explode(vector HitLocation,vector HitNormal){
   destroy();
}

function ProcessTouch (Actor Other, Vector HitLocation){}

defaultproperties{
        trail_count=1
        prev_location=(X=0.0,Y=0.0,Z=0.0)
        speed=3400.0
        MaxSpeed=500000.0
        Damage=1.0
        DrawType=DT_None
        bCollideActors=False
        bCollideWorld=False
}
