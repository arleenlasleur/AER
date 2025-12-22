class aeremirocket extends Projectile;
var bool launched;

#exec obj load file=..\Textures\Mine.utx package=Mine
#exec mesh import mesh=aeremimissile anivfile=Models\aeremimissile_a.3d datafile=Models\aeremimissile_d.3d x=0 y=0 z=0 mlod=0
#exec mesh origin mesh=aeremimissile x=0 y=0 z=0
#exec mesh sequence mesh=aeremimissile seq=All startframe=0 numframes=1
#exec meshmap new meshmap=aeremimissile mesh=aeremimissile
#exec meshmap scale meshmap=aeremimissile x=0.12805 y=0.12805 z=0.25611

function trigger(actor other, pawn eventinstigator){
   if(launched) return;
   launched = true;
   velocity = vector(rotation) * speed;
}

function processtouch(actor other, vector hitloc){ explode(vect(0,0,0),vect(0,0,0)); }
simulated function landed(vector hitnor){ explode(vect(0,0,0),vect(0,0,0)); }
simulated function hitwall(vector hitnor, actor wall){ explode(vect(0,0,0),vect(0,0,0)); }
function explode(vector hitloc,vector hitnor){
        local aerwpn aw;
        foreach radiusactors(class'aerwpn',aw,5000,location){
                aw.aeremi();
        }
        spawn(class'aeremiexplode');
        destroy();
}

defaultproperties{
  bDirectional=true
  lifespan=0.0
  launched=false
  speed=540
  MaxSpeed=50000
  DrawType=DT_Mesh
  Mesh=Mesh'aeremimissile'
  ScaleGlow=3.00000
  ambientglow=128.00000
  bCollideWhenPlacing=false
  bCollideActors=true
  bCollideWorld=true
  bBlockActors=true
  bBlockPlayers=true
  CollisionRadius=64.00000
  CollisionHeight=64.00000
  MultiSkins(0)=Texture'Mine.Base.Ironwalx'
  MultiSkins(1)=Texture'Mine.Base.MCMETL'
  MultiSkins(2)=Texture'Mine.Trim.Rustpl1'
}
