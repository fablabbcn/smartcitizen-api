FactoryGirl.define do
  factory :kit do
    name "Testing kit"
    description "A kit that was made for the test environment"

    factory :kit_with_components do
      id 9876567
      name 'kit_name'
      description 'kit_description'
      slug 'kit_slug'
      sensor_map '{"co": 16, "bat": 17, "hum": 13, "no2": 15, "nets": 21, "temp": 12, "light": 14, "noise": 7, "panel": 18}'

      after(:create) do |kit|
        Sensor.delete_all
        create(:sensor, id:17, name:'POM-3044P-R', description: 'test')
        create(:sensor, id:22, name:'HPP828E031', description: 'test')
        create(:sensor, id:23, name:'HPP828E031', description: 'test')
        create(:sensor, id:24, name:'BH1730FVC', description: 'test')
        create(:sensor, id:25, name:'MiCS-4514', description: 'test')
        create(:sensor, id:26, name:'MiCS-4514', description: 'test')
        create(:sensor, id:27, name:'Battery', description: 'test')
        create(:sensor, id:28, name:'Solar Panel', description: 'test')
        create(:sensor, id:31, name:'Microchip RN-131', description: 'test')

        Component.delete_all
        create(:component, id: 22, board: kit, sensor: Sensor.find(22), equation: '(175.72 / 65536.0 * x) - 53', reverse_equation: 'x')
        create(:component, id: 23, board: kit, sensor: Sensor.find(23), equation: '(125.0 / 65536.0  * x) + 7', reverse_equation: 'x')
        create(:component, id: 24, board: kit, sensor: Sensor.find(24), equation: 'x', reverse_equation: 'x/10.0')
        create(:component, id: 25, board: kit, sensor: Sensor.find(17), equation: 'Mathematician.table_calibration({0=>50,2=>55,3=>57,6=>58,20=>59,40=>60,60=>61,75=>62,115=>63,150=>64,180=>65,220=>66,260=>67,300=>68,375=>69,430=>70,500=>71,575=>72,660=>73,720=>74,820=>75,900=>76,975=>77,1050=>78,1125=>79,1200=>80,1275=>81,1320=>82,1375=>83,1400=>84,1430=>85,1450=>86,1480=>87,1500=>88,1525=>89,1540=>90,1560=>91,1580=>92,1600=>93,1620=>94,1640=>95,1660=>96,1680=>97,1690=>98,1700=>99,1710=>100,1720=>101,1745=>102,1770=>103,1785=>104,1800=>105,1815=>106,1830=>107,1845=>108,1860=>109,1875=>110},x)', reverse_equation: 'x')
        create(:component, id: 26, board: kit, sensor: Sensor.find(25), equation: 'x', reverse_equation: 'x/1000.0')
        create(:component, id: 27, board: kit, sensor: Sensor.find(26), equation: 'x', reverse_equation: 'x/1000.0')
        create(:component, id: 28, board: kit, sensor: Sensor.find(27), equation: 'x', reverse_equation: 'x/10.0')
        create(:component, id: 29, board: kit, sensor: Sensor.find(28), equation: 'x', reverse_equation: 'x/1000.0')
        create(:component, id: 30, board: kit, sensor: Sensor.find(31), equation: 'x', reverse_equation: 'x')
        create(:component, id: 31, board: kit, sensor: Sensor.find(31), equation: 'x', reverse_equation: 'x')
      end
    end
  end

end
