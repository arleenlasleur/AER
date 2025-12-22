class aerhurt extends Inventory;
var int holes;
var bool bleed_mild, bleed_med, bleed_severe, bleed_fatal;
var int apply_damage,pending_damage;
var float damage_timer,explode_timer,heal_timer,blood_timer,moveslow_timer,hurt_period,lasthit_timer;
var float bleed_lifespan;

simulated function tick(float f){
   local pawn p;
   local aerblooddrop b;
   local vector old_velocity;
   if(holes < 2) return;
   heal_timer -= f;
   blood_timer -= f;
   damage_timer -= f;
   if(!bleed_fatal) bleed_lifespan -= f;
     else apply_damage = 15;
   p = pawn(owner);
   if(heal_timer <= 0){
      if(bleed_severe || bleed_fatal) return;
      if(holes > 3) holes--;
      heal_timer = 0.65;
   }
   if(p == none) return;
   if(p.velocity.z >= 160) p.velocity.z = 20;
   if(moveslow_timer > 0){
      p.groundspeed  = p.default.groundspeed * 0.01;
      p.waterspeed   = p.default.waterspeed * 0.01;
      old_velocity   = p.velocity;
      old_velocity.x = 0.0;
      old_velocity.y = 0.0;
      p.velocity    = old_velocity;
      moveslow_timer -= f;
   }else{
      p.groundspeed = p.default.groundspeed;
      p.waterspeed  = p.default.waterspeed;
   }
   if(p.health < 0) destroy();
   if(blood_timer <= 0 && bleed_lifespan > 0){
      b = spawn(class'aerblooddrop',,,p.location);
      if(b != none) b.initfor(p);
      blood_timer = 0.2;
   }
   if(damage_timer <= 0 ){
      if(pending_damage > 0) pending_damage -= apply_damage;
//    if(bleed_lifespan > 0) p.TakeDamage(apply_damage, instigator, p.location, 3 * Normal(p.Velocity), 'shot');
      invulner_proof_damage(apply_damage,p);
      damage_timer = hurt_period;
   }
}

function postbeginplay(){
   lasthit_timer = 0.0;
}

function addholes(){   // todo add clamped fatness
   local pawn p;
   local int tmp_apply_damage;
   p = pawn(owner);
   if(p == none) return;
   lasthit_timer = level.timeseconds;
   tmp_apply_damage = 0;
   if(pending_damage > 120){       // claim undone dmg, 1000 max   // todo downscale it according to accuracy
      pending_damage -= 120;                                       // accuracy = vsize(hitloc - chest)
      tmp_apply_damage = 120; // these was 1000                    // penmon.write accuracy instead of apply_dmg
   }else{
      tmp_apply_damage = pending_damage;
      pending_damage = 0;
   }
// p.TakeDamage(tmp_apply_damage, instigator, p.location, 3 * Normal(p.Velocity), 'shot');
   invulner_proof_damage(tmp_apply_damage,p);
   moveslow_timer = 0.08; // was .11
   holes++;
   if(bleed_lifespan <= 0) bleed_lifespan = 0.9;
   bleed_lifespan += 0.2;
   if(holes > 2 && !bleed_mild)   bleed_mild = true;
   if(holes > 4 && !bleed_med)    bleed_med  = true;
   if(holes > 7 && !bleed_severe) bleed_severe = true;
   if(holes > 9 && !bleed_fatal)  bleed_fatal = true;
   if(bleed_mild)   hurt_period=0.40;
   if(bleed_med)    hurt_period=0.24;
   if(bleed_severe && bleed_lifespan > 2.1) bleed_lifespan = 2.1;
                   if(bleed_lifespan > 1.5) bleed_lifespan = 1.5;
   if(bleed_severe) hurt_period=0.13;
   if(bleed_fatal)  hurt_period=0.07;
}

function invulner_proof_damage(int ndamage, pawn targ){
   local int health_before,reduced_damage;
   local vector dmomentum,hiteffectloc;
   local bool alreadydead;
   local playerpawn pptarg;
   local scriptedpawn sptarg;
   local class<carcass> carc_class;
   local carcass carc;
   if(targ == none) return;
   if(instigator == none) return;
   dmomentum = 3*Normal(targ.velocity);
   health_before = targ.health;
   reduced_damage = ndamage;
   hiteffectloc = targ.location;
   hiteffectloc.z += (targ.CollisionHeight / 3);
   targ.TakeDamage(ndamage, instigator, hiteffectloc, dmomentum, 'shot');
   if(health_before > targ.health) return;             // takedamage() call successful
   carc_class = none;
   if (targ.inventory != none) reduced_damage = targ.inventory.reducedamage(reduced_damage, 'shot', hiteffectloc);
   targ.health -= reduced_damage;
   targ.LastDamageInstigator = instigator;             // handle engine.u takedamage stuff
   targ.LastDamageHitLocation = hiteffectloc;          // which was evaded by mercenary-like return
   targ.LastDamageMomentum = dmomentum;
   targ.LastDamageType = 'shot';
   targ.LastDamageTime = level.timeseconds;
   targ.bLastDamageSpawnedBlood = false;
   alreadydead = (targ.Health <= 0);
   if(targ.physics == PHYS_None) targ.setmovementphysics();
   if(targ.physics == PHYS_Walking) dmomentum.z = fmax(dmomentum.z, 0.4 * vsize(dmomentum));
   dmomentum /= targ.mass;
   targ.addvelocity(dmomentum);
   if(targ.carrieddecoration != none) targ.dropdecoration();
   if(targ.health>0){
      targ.damageattitudeto(instigator);                    
      targ.playhit(reduced_damage, targ.location, 'shot', dmomentum.z);
   }else if(!alreadydead){
      targ.nextstate = '';                                            
      targ.playdeathhit(reduced_damage, targ.location, 'shot');
      if(reduced_damage > targ.mass) targ.health = -1 * reduced_damage;
      targ.enemy = instigator;
      targ.died(instigator, 'shot', targ.location);
   }else{
      hiteffectloc = targ.location;
      hiteffectloc.z -= targ.collisionheight/2;
      hiteffectloc.z -= 32;
      if(targ.bIsPlayer){
         targ.HidePlayer();
         targ.GotoState('Dying');
         pptarg = playerpawn(targ);
         if(pptarg != none) carc_class = pptarg.carcasstype;
      }else{
         sptarg = scriptedpawn(targ);
         if(sptarg != none) carc_class = sptarg.carcasstype;
         targ.Destroy();
      }
      if(carc_class != none){
         carc = spawn(carc_class,,,hiteffectloc,rot(0,0,0));
         if(carc != none){
            carc.setPhysics(PHYS_Falling);
            carc.group = 'AERIGNORE';
//            carc.TakeDamage(500000, instigator, carc.location, vect(0,0,40000), 'shot');
         }
      }
   }
   targ.makenoise(1.0);
}

defaultproperties{
        holes=0
        apply_damage=5
        pending_damage=0
        damage_timer=0.0
        explode_timer=0.0
        heal_timer=0.0
        blood_timer=0.0
        hurt_period=0.73
        bleed_lifespan=1.1
        bleed_mild=False
        bleed_med=False
        bleed_severe=False
        bleed_fatal=False
}
