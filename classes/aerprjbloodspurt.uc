class aerprjbloodspurt extends Projectile;

  // plshelpme:  even though large momentum, blood persist flying towards instigator
  //             more often when aggro pawn runs towards instigator (maybe this is affected by pawn velocity/speed)

var int         trail_count,
                trail_maxtotal;
var actor       init_targ;
var vector      prev_location;

function postbeginplay(){
   local aerblooddrop b;
   local vector x,y,z;
   local byte i;
   trail_maxtotal = 32 + rand(12);
   prev_location = location;
   if(init_targ == none) return;
   getaxes(rotation,x,y,z);
   for(i=1;i<=3;i++){
     b = spawn(class'aerblooddrop',,,Location-x*15*i);
     if(b != none) b.initfor(init_targ);
   }
}

function timer(){
   local aerblooddrop b;
   // todo stop spawning after 768...1024 dist
   if(vsizesq(prev_location-location) >= 1024){  // 32uu
      prev_location = location;
      trail_count++;
//      broadcastmessage("xx: "$trail_count$" # "$location);
      if(trail_count>trail_maxtotal) destroy();
      if(init_targ != none){
         b = spawn(class'aerblooddrop');
         if(b != none){
            b.trail_count = trail_count;
            b.initfor(init_targ);
         }
      }
   }
   settimer(0.01,true);
}
auto state Flying{
   function BeginState(){
      settimer(0.01,true);
   }
Begin:
   velocity = vector(rotation) * speed;
}

function ProcessTouch (Actor Other, Vector HitLocation){}
simulated function Landed(vector HitNormal){  destroy();  }
simulated function HitWall(vector HitNormal, actor Wall){  destroy();  }
function Explode(vector HitLocation,vector HitNormal){  destroy();  }

defaultproperties{
        trail_count=1
        init_targ=None
        prev_location=(X=0.0,Y=0.0,Z=0.0)
        speed=7500.0
        MaxSpeed=500000.0
        Mass=200.0
        Physics=PHYS_Falling
        DrawType=DT_None
}
