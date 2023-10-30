var phillyCityLights = null;
var phillyTrans = new RuntimeSprite();
var trainSound = null;
var lightFadeShader = null;

function create() {
    var bg = new RuntimeSprite("philly/sky", -100);
    bg.scrollFactor.set(0.1, 0.1);
    addBehindGf(bg);

    var city = new RuntimeSprite("philly/city", -10);
    city.scrollFactor.set(0.3, 0.3);
    city.setScale(0.85);
    addBehindGf(city);

    lightFadeShader = new RuntimeShader("BuildingShader");
    phillyCityLights = new RuntimeGroup();

    addBehindGf(phillyCityLights);

    for (i in 0...5) {
        var light = new RuntimeSprite("philly/win" + i, city.x);
        light.scrollFactor.set(0.3, 0.3);
        light.visible = false;
        light.setScale(0.85);
        light.shader = lightFadeShader;
        phillyCityLights.add(light);
    }
}