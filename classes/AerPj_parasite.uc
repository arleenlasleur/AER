class AerPj_parasite extends TentacleProjectile;
var float timer_falldown,timer_rescan;
var playerpawn hate_target;

auto state flying{
   simulated function BeginState(){ Velocity = Vector(Rotation)*speed*(1+(frand()*0.4)); }
   begin:
   Sleep(7.0);
   explode(Location, vect(0,0,0));
}

function ProcessTouch (Actor Other, Vector HitLocation){
   local vector momentum;
   if((Tentacle(Other) != none) || (TentacleProjectile(Other) != none)) return;
   if(Role != ROLE_Authority) destroy();
   momentum = 10000.0 * Normal(Velocity);
   Other.TakeDamage(Damage, instigator, HitLocation, momentum, 'stung');
   destroy();
}
function tick(float f){
//   local rotator r;
   local vector MoveDir,CurrentDir,x,y,z;
   local playerpawn pp;
   getaxes(self.rotation,x,y,z);
   timer_falldown -= f;
   if(timer_falldown > 0.0) return;
      timer_falldown = 0.04;
   if(level.timeseconds-timer_rescan >= 0.5 && hate_target==none){
      foreach radiusactors(class'playerpawn',pp,1280){ hate_target = pp; break; }
      timer_rescan = level.timeseconds;
   }
   if(hate_target != none){
      MoveDir = Normal(hate_target.location      - self.location);
      if(speed<4000) speed += 40;
   }else{
      MoveDir = Normal(self.location + 10000.0*x - self.location);
      if(speed>400) speed -= 40;
   }
   CurrentDir = Normal(Velocity);
   if((MoveDir Dot CurrentDir) < 0.93) MoveDir = Normal(CurrentDir + MoveDir * 0.12);
   Velocity = MoveDir*Speed;
   SetRotation(rotator(Velocity));
//   r = self.rotation;
//   if(r.pitch <= 12300) disable('tick');
//   r.pitch -= ((800.0 * frand()) + 400.0);
//   setrotation(r);
//   velocity = Vector(Rotation) * speed;
}

function postbeginplay(){
   local playerpawn pp;
   foreach radiusactors(class'playerpawn',pp,1280) hate_target = pp;
   timer_rescan = level.timeseconds;
   timer_rescan += 0.6;              // min sleep time
   timer_rescan += (frand() * 0.9);
}

defaultproperties{
  DrawScale=0.32
  speed=1000
  maxspeed=4000
  hate_target=none
}
