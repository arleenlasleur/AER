class AerGr_FP extends Effects;
var bool ena_playfire;

function query_fire(){
   ena_playfire = true;
}

function tick(float f){
   if(!ena_playfire) return;
//   playsound(sound'aerfire', SLOT_None, 32);
   ena_playfire = false;
}

function timer(){
   if(vsizesq(velocity) > 0) velocity = vect(0,0,0);
}

function beginplay(){
   setTimer(0.3,true);
}

singular function zonechange(zoneinfo nz){
   velocity = vect(0,0,0);
}

defaultproperties{
   Physics=PHYS_MovingBrush
   PhysRate=9999.0
   ena_playfire=false
}
