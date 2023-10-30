function create() {
    var bg = new RuntimeSprite("stageback", -600, -200);
    bg.scrollFactor.set(0.9, 0.9);
    addBehindGf(bg);

    var stageFront = new RuntimeSprite("stagefront", -650, 600);
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.setScale(1.1);
    stageFront.active = false;
    addBehindGf(stageFront);

    var stageCurtains = new RuntimeSprite("stagecurtains", -500, -300);
    stageCurtains.scrollFactor.set(1.3, 1.3);
    stageCurtains.setScale(0.9);
    stageCurtains.active = false;
    
    addBehindGf(stageCurtains);
}