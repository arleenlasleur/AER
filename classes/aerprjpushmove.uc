class aerprjpushmove extends Projectile;
var int    trail_count;
var vector prev_location;
var bool DisablePushCorridorBalance;

function postbeginplay(){
   prev_location = location;
   settimer(0.01,false);
}

function timer(){
   local projectile pj;
   local rotator r;
   local vector l;
   local float obstacleradius;
   obstacleradius = DisablePushCorridorBalance ? 448 : 64 + 6*trail_count;
   if(vsizesq(prev_location-location) >= 1024){
      prev_location = location;
      foreach RadiusActors(class'projectile', pj, obstacleradius){
         if(pj.instigator == instigator) continue;
         if(pj.group == 'AERDeaimIgnore') continue;
         if(pj.isa('aerprjhurtdmg')) continue;
         r = pj.rotation;
         l = pj.location;           // orig  5%   15%
         r.pitch -= frand() * 1146; // 7640  382  1146
         r.pitch += 573;            // 3820  191  573
         r.yaw -= frand() * 1092;   // 7280  364  1092
         r.yaw += 546;              // 3640  182  546
         pj.setrotation(r);
         pj.velocity=pj.speed * vector(r);
         pj.group = 'AERDeaimIgnore';
      }
      trail_count++;
   }
   if(trail_count >= 96) destroy();
   settimer(0.01,true);
}
auto state Flying{
   function BeginState(){
      settimer(0.1,true);
   }
Begin:
   velocity = vector(rotation) * speed;
}

function Explode(vector HitLocation,vector HitNormal){
   local vector x,y,z;
   local aerffieldblk fwall;
   local aerprjpushmove m;
   local bool ena_chainspawn;
   ena_chainspawn = false;
   foreach radiusactors(class'aerffieldblk',fwall,32) ena_chainspawn = true;
   if(!ena_chainspawn) destroy();
   getaxes(rotation,x,y,z);
   m = spawn(self.class,,,HitLocation + HitNormal + x*128);             // attemp to spawn
   if(m != none){
      m.trail_count = self.trail_count;
      m.DisablePushCorridorBalance = self.DisablePushCorridorBalance;
      m.MomentumTransfer = self.MomentumTransfer;
   }
   destroy();
}

function ProcessTouch (Actor Other, Vector HitLocation){
   local mover mbo;
   local aerwpn w;
   local byte b;
   if(other == instigator) return;
   if(!other.bispawn){
      other.takedamage(250,instigator,hitlocation,7000*normal(velocity),'exploded');
      if(bool(creaturecarcass(other))) foreach RadiusActors(class'aerwpn', w, 6400){
         b = clamp(vsize(w.location - location)/256,1,25);
         b = clamp(25-b,1,25);
         w.do_penmon_write(1,b);
      }
   }
   mbo = mover(other);
   if(mbo == none || instigator == none) return;
   if(mbo.isInState('BumpOpenTimed')) mbo.bump(instigator);
   explode(hitlocation,vect(0,0,0));
}

defaultproperties{
        trail_count=1
        prev_location=(X=0.0,Y=0.0,Z=0.0)
        DisablePushCorridorBalance=False
        speed=3500.0
        MaxSpeed=500000.0
        Damage=1.0
        CollisionRadius=4.0
        CollisionHeight=4.0
        DrawType=DT_None
        bCollideWorld=False
}
