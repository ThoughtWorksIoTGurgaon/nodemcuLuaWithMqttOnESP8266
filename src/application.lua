
-- file : application.lua
local module = {}
m = nil

-- Sends a simple ping to the broker
local function send_ping()
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()
    pin=5
    other_pin=2
    gpio.mode(pin,gpio.OUTPUT)
    gpio.mode(other_pin,gpio.OUTPUT)


    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data)
      if data ~= nil then
        print(topic .. ": :" .. data)
        -- do something, we have received a message
      end
      if(data == 'high') then
          gpio.write(pin,gpio.HIGH)
          gpio.write(other_pin,gpio.LOW)
      elseif data == 'low' then
          gpio.write(pin,gpio.LOW)
          gpio.write(other_pin,gpio.HIGH)
      end
    end)
    -- Connect to broker
    m:connect(config.HOST, config.PORT, 0, 1, function(con)
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end)

end

function module.start()
  mqtt_start()
end

return module
