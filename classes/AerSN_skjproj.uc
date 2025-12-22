class AerSN_skjproj extends SpawnNotify;

simulated event Actor SpawnNotification(Actor A){
   local skaarjprojectile sp;
   sp = skaarjprojectile(a);
   if(sp==none) return a;
   sp.drawscale /= 3;
   sp.speed *= 1.7;
   sp.velocity = vector(sp.rotation) * sp.speed;
//   if(a.isa('HumanCarcass')) return A;          // skip player corpses
   return a;
}

defaultproperties{
   ActorClass=Class'UnrealShare.SkaarjProjectile'
   bHidden=True
}
