// =============================================
// explode tarydium poisoned corpses
// helpme: need iHitByTarydiumBullet counter
//         for faster/slower/no explosion
// =============================================
class AerWk_exploder extends Info;
var actor targ;
var float explode_timer;

simulated function tick(float f){
//   local aerwpn w;
//   local byte b;
//   local vector l;
   if(targ==none) destroy();
   explode_timer -= f;
   if(explode_timer <= 0){
      if(targ.fatness < 210) targ.fatness += (rand(8)+1); //was 4+1
      else{
      /*   targ.TakeDamage(500000, instigator, targ.location, vect(0,0,40000), 'exploded');
         l = targ.location;
         l.z += 32;
         spawn(class'AerWk_expparasite',,,l);
         foreach RadiusActors(class'aerwpn', w, 6400){
            b = clamp(vsize(w.location - location)/256,1,25);
            b = clamp(25-b,1,25);
            w.do_penmon_write(1,b);
         }
         destroy();  */     // tmp disabled, todo: sense player proximity or explode by damage. dont explode if nonfat body
      }
      explode_timer = 0.13;
   }
}

simulated function postbeginplay(){
   disable('tick');
}

defaultproperties{
        explode_timer=0.0
        targ=None
        LifeSpan=30.0
}
