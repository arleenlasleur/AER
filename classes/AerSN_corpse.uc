class AerSN_corpse extends SpawnNotify;
var aerwpn aerw;

simulated event Actor SpawnNotification(Actor A){
   local weapon w;
   local CreatureCarcass cc;
//    local AerGr_bullethole bh;
   local AerWk_exploder ce;
//    foreach RadiusActors(class'AerGr_bullethole', bh, 140, a.location) bh.destroy();
   foreach RadiusActors(class'weapon', w, 1024, a.location){
      if(bool(aerwpn(w))) continue;
      w.ambientglow=128;
      w.setcollision(false,false,false);
   }
   if(a.isa('HumanCarcass')) return A;          // skip player corpses
   if(caps(string(a.group)) == 'AERIGNORE') return A;    // skip non-tarydium-poisoned corpses
   if(frand() > 0.4){                      // prevent files on 40% corpses
      cc = CreatureCarcass(a);
      if(cc!=none){                        // this should be always true but I check anyway
         if(cc.bugs != none){
            cc.bugs.destroy();
            ce = spawn(class'AerWk_exploder',,,a.location);   // enable parasite explode of them
            if(ce != none){
               ce.targ = a;
               ce.enable('tick');
            }
         }
      }
   }
   return A;
}

defaultproperties{
        ActorClass=Class'UnrealShare.CreatureCarcass'
        bHidden=True
}
