class AerGr_FP extends Effects;
#exec audio import file="sounds\aerfire_impact2.wav" name="aerfire" package="AER" group="Sound"   // #3, slow rpm
//#exec audio import file="sounds\aerfire_mtlkick.wav" name="aerfire" package="AER" group="Sound"   // #3, slow rpm
var bool ena_playfire;

function query_fire(){
   ena_playfire = true;
}

function tick(float f){
   if(!ena_playfire) return;
   playsound(sound'aerfire', SLOT_None, 32);
   ena_playfire = false;
}

defaultproperties{
   ena_playfire=false
}