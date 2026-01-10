class AerGr_FP extends Effects;
#exec audio import file="sounds\aerfire_impact2.wav" name="aerfire" package="AER" group="Sound"   // #3, slow rpm
//#exec audio import file="sounds\aerfire_mtlkick.wav" name="aerfire" package="AER" group="Sound"   // #3, slow rpm

#exec audio import file="sounds\newfire\aerfirehfpre.wav"  name="aerfirepre"  package="AER" group="Sound"
#exec audio import file="sounds\newfire\aerfirehfloop.wav" name="aerfireloop" package="AER" group="Sound"
#exec audio import file="sounds\newfire\aerfirehfpast.wav" name="aerfirepast" package="AER" group="Sound"

var bool ena_playfire;
//var aerwpn w;
//var bool last_pw_sens_fire;
//var float queue_loop_snd,queue_past_snd;

function query_fire(){
   ena_playfire = true;
}

function tick(float f){
   if(!ena_playfire) return;
/*   if(w==none) return;
   queue_loop_snd -= f;
   queue_past_snd -= f;
   if(!last_pw_sens_fire && w.pw_sens_fire){
      playsound(sound'aerfirepre', SLOT_None, 32);
      queue_loop_snd = 0.020; // length of pre sound
      last_pw_sens_fire = true;
   }
   if(queue_loop_snd<0 && last_pw_sens_fire && w.pw_sens_fire){
      playsound(sound'aerfireloop', SLOT_None, 32);
      queue_loop_snd = 0.200; // length of loop sound
   }
   if(last_pw_sens_fire && !w.pw_sens_fire){
      queue_past_snd = queue_loop_snd; // attempt to sync when loopsnd ends
      last_pw_sens_fire = false;
   }
   if(queue_past_snd<0 && !last_pw_sens_fire){
//      playsound(sound'aerfirepast', SLOT_None, 32);
      ena_playfire = false;
   } */
//             playsound(sound'aerfire', SLOT_None, 32);
//   last_pw_sens_fire = w.pw_sens_fire;
   ena_playfire = false;
}

defaultproperties{
   ena_playfire=false
//   last_pw_sens_fire=false
}