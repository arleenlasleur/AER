class aerblooddrop extends pheart;
#exec mesh import mesh="aerbloodblast" anivfile="models\aerbloodblast_a.3d" datafile="models\aerbloodblast_d.3d" x=0 y=0 z=0 mlod=0
#exec mesh origin mesh="aerbloodblast" x=0 y=0 z=0
#exec mesh sequence mesh="aerbloodblast" seq=All startframe=0 numframes=1
#exec meshmap new meshmap="aerbloodblast" mesh="aerbloodblast"
#exec meshmap scale meshmap="aerbloodblast" x=0.03131 y=0.03131 z=0.06262

#exec texture import file="textures\blood\aerblddrp01.png" name="aerblddrp01" package="AER" group="Blood" mips=1 flags=0 btc=-2
#exec texture import file="textures\blood\aerblddrp02.png" name="aerblddrp02" package="AER" group="Blood" mips=1 flags=0 btc=-2
#exec texture import file="textures\blood\aerblddrp03.png" name="aerblddrp03" package="AER" group="Blood" mips=1 flags=0 btc=-2
#exec texture import file="textures\blood\aerblddrp04.png" name="aerblddrp04" package="AER" group="Blood" mips=1 flags=0 btc=-2
#exec texture import file="textures\blood\aerblddrp05.png" name="aerblddrp05" package="AER" group="Blood" mips=1 flags=0 btc=-2
#exec texture import file="textures\blood\aerblddrp06.png" name="aerblddrp06" package="AER" group="Blood" mips=1 flags=0 btc=-2
#exec texture import file="textures\blood\aerblddrp07.png" name="aerblddrp07" package="AER" group="Blood" mips=1 flags=0 btc=-2

var texture bloodtex[7];
var int trail_count;
var float entry_dist;                // dist between bloodinstigator and enemy when bullet spilled blood, destroy if reduces

simulated function ClientExtraChunks(bool bSpawnChunks){}

simulated function ZoneChange( ZoneInfo NewZone ){
        if( NewZone.bWaterZone || NewZone.bDestructive || (NewZone.bPainZone  && (NewZone.DamagePerSec > 0)) ) Destroy();
}

function Initfor(actor Other){
        local vector RandDir;
        local rotator r;
        if(Region.Zone.bWaterZone) destroy();
        bDecorative = false;
        MultiSkins[0]=bloodtex[rand(6)];
        Drawtype=DT_Mesh;
        RandDir = (40+trail_count) * FRand() * VRand(); // was 700
        RandDir.Z = (80+trail_count) * FRand() - (40+trail_count);
        Velocity = (0.2 + FRand()) * (other.Velocity + RandDir) * 5;
        r = rotation;
        r.pitch = 0;
        setRotation(r);
        if(instigator == none) destroy();
        entry_dist = vsize(instigator.location - location);
        if ( Other != None && Other.isa('ScriptedPawn')) bGreenBlood = ScriptedPawn(Other).bGreenBlood;
         else if ( CreatureCarcass(Other) != None )  bGreenBlood = CreatureCarcass(Other).bGreenBlood;
         else if ( (CreatureChunks(Other) != None) ) bGreenBlood = CreatureChunks(Other).bGreenBlood;
        setTimer(0.2,true);
}

function ChunkUp(int Damage){
        destroy();
}

simulated function Landed(vector HitNormal){
        local rotator finalRot;
        local Bloodsplat2 BS2;
        if(FRand()>0.12) destroy();
        finalRot = Rotation;
        finalRot.Roll = 0;
        finalRot.Pitch = 0;
        setRotation(finalRot);
        if(Level.NetMode != NM_DedicatedServer){
                BS2=Spawn(class'BloodSplat2',Owner,,,Rotator(HitNormal));
                if (bGreenBlood && BS2 != none) BS2.Green();
        }
        destroy();
}

simulated function HitWall(vector HitNormal, actor Wall){
        local float speed;
        local Bloodsplat2 BS2;
        if(FRand()>0.92) destroy();
        Velocity = 0.8 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
        Velocity.Z = FMin(Velocity.Z * 0.8, 700);
        speed = VSize(Velocity);
        if(speed < 120 ){
           bBounce = false;
           Disable('HitWall');
        }
        if (Level.Netmode != NM_DedicatedServer) BS2=Spawn(class'BloodSplat2',Owner,,,Rotator(HitNormal));
        if (bGreenBlood && BS2 != none) BS2.Green();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType){
        if (bStatic || bDeleteme) return;
        SetPhysics(PHYS_Falling);
        bBobbing = false;
        Velocity += momentum/Mass;
        CumulativeDamage += Damage;
        If ( Damage > FMin(15, Mass) || (CumulativeDamage > Mass) ) destroy();
}

simulated function Timer(){
        // plshelpme: some blood persists flying towards instigator, even though momentum is large. can't get rid of that
        if(entry_dist == 0) destroy();
        if(entry_dist < vsize(instigator.location - location)) destroy();
        setTimer(0.2,true);
}

auto state dead{}

defaultproperties{
        trail_count=1
        entry_dist=0.0
        bloodtex(0)=Texture'AER.Blood.aerblddrp01'
        bloodtex(1)=Texture'AER.Blood.aerblddrp02'
        bloodtex(2)=Texture'AER.Blood.aerblddrp03'
        bloodtex(3)=Texture'AER.Blood.aerblddrp04'
        bloodtex(4)=Texture'AER.Blood.aerblddrp05'
        bloodtex(5)=Texture'AER.Blood.aerblddrp06'
        bloodtex(6)=Texture'AER.Blood.aerblddrp07'
        TrailSize=0.0
        bMustSpawnChunks=False
        LifeSpan=7.0
        DrawScale=0.37
        Mass=40000.0
        Mesh=Mesh'AER.aerbloodblast'
        DrawType=DT_None
        bBounce=False
}
