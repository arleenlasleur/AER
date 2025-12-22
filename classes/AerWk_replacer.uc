// =============================================
// ??? mutator
// =============================================
class AERWk_replacer extends Mutator;
var bool mutator_set;
/*function ModifyPlayer (Pawn Other){
        Other.Health = 300;
        if ( NextMutator != None ) NextMutator.ModifyPlayer(Other);
        GiveWeapon(Other, "EXU.PiddledoperMP", true);
}*/

 // enable this for inlevel usage. if mut added via ?mutator= command line, eats 100% CPU.
/*function PreBeginPlay() {
        if (mutator_set) return;
        mutator_set = true;
        Self.NextMutator = Level.Game.BaseMutator.NextMutator;
        Level.Game.BaseMutator.NextMutator = Self;
} */

function bool CheckReplacement(actor other, out byte bSuperRelevant){
   bSuperRelevant = 0;
   if(other.isa('asmdammo')){    ReplaceWith(other, "AER.AerAm_core");  return false; }
   if(other.isa('clip')){        ReplaceWith(other, "AER.AerAm_shard"); return false; }
   if(other.isa('stingerammo')){ ReplaceWith(other, "AER.AerAm_shard"); return false; }
//   if(other.isa('weapon') && other.ambientglow==255){ other.ambientglow = 254; return false; }
   return true;
}

defaultproperties{
        mutator_set=False
}
