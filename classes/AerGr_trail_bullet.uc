class AerGr_trail_bullet extends Effects;
var int i;

function postbeginplay(){
   LightBrightness = 0;
   disable('timer');
}
function touch(actor other){
   if(!bool(aerprjhurtdmg(other))) return;
   LightBrightness = i*1;
   enable('timer');
   settimer(0.07,false);
}

function timer(){
   if(i>0){
      LightBrightness = i*1;
      i--;
   }else destroy();
   settimer(0.005,true);
}

defaultproperties{
   i=25
   LifeSpan=3.2
   RemoteRole=ROLE_None
   DrawType=DT_None
   AmbientGlow=0
   bCollideWorld=false
   bCollideWhenPlacing=false
   bCollideActors=true
   bBlockActors=false
   CollisionHeight=64
   CollisionRadius=64
   LightEffect=LE_NonIncidence
   LightType=LT_Steady
   LightBrightness=0
   LightHue=170
   LightSaturation=195
   LightRadius=5
}
