// ==================================================
// Forcefield projectile reactor, allows AER projs
// to pass thru F2 field by tmp disable it
// ==================================================
class AerWk_FFR extends Triggers;
var AerGr_ffield field_targ;

function touch(actor other){
   if(!bool(aerprjhurtdmg(other))) return;
   if(field_targ == none) return;
   field_targ.reactive_open_wall();
}

defaultproperties{
   CollisionHeight=192.0
   CollisionRadius=192.0
}