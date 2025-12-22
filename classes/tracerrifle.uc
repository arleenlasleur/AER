class tracerrifle extends rifle;

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z){
        local pawn p;
        local tracerprjhurtdmg pj;
        p = pawn(owner);
        if(p == none) return;
        pj = spawn(class'tracerprjhurtdmg',,,p.location,p.viewrotation);
        if(pj == none) return;
        pj.gotostate('Launch');
}
