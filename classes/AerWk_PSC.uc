// =============================================
// ???  playerstarts cleaner: shitty aercore spawns fix
// =============================================
class AerWk_PSC extends Info; 

function postbeginplay(){
  local AerAM_core a;
  local playerstart ps;
  foreach allactors(class'playerstart',ps){
     foreach radiusactors(class'AerAm_core',a,32,ps.location) a.destroy();
  }
}
