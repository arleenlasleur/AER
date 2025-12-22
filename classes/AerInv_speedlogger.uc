class AerInv_speedlogger extends Inventory;
var float speed_hist[10];
var float speed_avg;
var float timer_calc;
var pawn p;

function tick(float f){
   local byte i;
   local vector x,y,z,vel_enemy;
   if(p==none) return;
   if(p.enemy==none) return;
   timer_calc -= f;
   if(timer_calc > 0) return;
   timer_calc = 0.1;
   getaxes(rotator(p.location - p.enemy.location),x,y,z);
   vel_enemy = velocity;
   vel_enemy.x *= x.x;
   vel_enemy.y *= y.y;
   vel_enemy.z *= z.z;
   for(i=1;i<10;i++) speed_hist[i-1] = speed_hist[i];
   speed_hist[9] = vsize(vel_enemy);
}

function postbeginplay(){
   local byte i;
   for(i=0;i<10;i++) speed_hist[i] = 0.0;
   if(p==none && owner!=none) p = pawn(owner);
}

defaultproperties{
  p=none
}