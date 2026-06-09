-- wifi_ethernet_toggle.lua
-- Force Wi-Fi off while wired Ethernet is active.
-- Detect Ethernet/Wi-Fi devices by hardware port name so the same script
-- works on MacBook (USB-C hub "USB 10/100/1000 LAN") and Mac mini (built-in
-- "Ethernet"). No hardcoded en-numbers.

local M = {}

local log = hs.logger.new("wifi-eth", "info")
local configStore = nil
local wifiWatcher = nil
local lastEthernetActive = nil

-- Return a list of BSD device names for all hardware ports matching
-- `portMatcher(portName) -> bool`.
local function findDevices(portMatcher)
  local devs = {}
  local out, ok = hs.execute("/usr/sbin/networksetup -listallhardwareports", false)
  if not ok or not out then return devs end
  local currentPort = nil
  for line in out:gmatch("[^\n]+") do
    local port = line:match("^Hardware Port:%s*(.+)$")
    if port then
      currentPort = port
    else
      local dev = line:match("^Device:%s*(%S+)")
      if dev and currentPort and portMatcher(currentPort) then
        table.insert(devs, dev)
      end
      if dev then currentPort = nil end
    end
  end
  return devs
end

-- Matches ports that look like a real wired Ethernet. Excludes Thunderbolt
-- Bridge (virtual) and raw Thunderbolt N (not Ethernet). Phantom "Ethernet
-- Adapter (enN)" entries survive the regex but are filtered by the
-- active-IP check in ethernetActive().
local function isEthernetPort(port)
  if port:match("Thunderbolt Bridge") then return false end
  if port:match("^Thunderbolt %d") then return false end
  return port:match("Ethernet") ~= nil or port:match("LAN$") ~= nil
end

local function ethernetActive()
  for _, dev in ipairs(findDevices(isEthernetPort)) do
    local details = hs.network.interfaceDetails(dev)
    if details and details.IPv4 and details.IPv4.Addresses
       and #details.IPv4.Addresses > 0 then
      return true
    end
  end
  return false
end

local function triggerSketchybar()
  hs.execute("/opt/homebrew/bin/sketchybar --trigger network_change >/dev/null 2>&1 &", false)
end

local function apply(reason)
  local active = ethernetActive()
  if active then
    -- Aggressive: always enforce Wi-Fi off while Ethernet is up,
    -- even if the user (or another tool) toggles it on.
    hs.wifi.setPower(false)
    if lastEthernetActive ~= true then
      log.i(string.format("Ethernet up (%s) -> Wi-Fi off", reason))
      triggerSketchybar()
    else
      -- Silent enforcement on repeat events; no log spam.
      triggerSketchybar()
    end
  else
    -- Ethernet not active: turn Wi-Fi on once on transition.
    -- On fresh startup with no Ethernet, leave Wi-Fi as-is (respect user state).
    if lastEthernetActive == true then
      log.i(string.format("Ethernet down (%s) -> Wi-Fi on", reason))
      hs.wifi.setPower(true)
      triggerSketchybar()
    end
  end
  lastEthernetActive = active
end

function M.start()
  apply("startup")
  configStore = hs.network.configuration.open()
  configStore:setCallback(function() apply("network change") end)
  configStore:monitorKeys({ "State:/Network/Global/IPv4" }, true)
  configStore:start()

  wifiWatcher = hs.wifi.watcher.new(function() apply("wifi change") end)
  wifiWatcher:start()

  log.i("wifi_ethernet_toggle started (aggressive mode)")
end

function M.stop()
  if configStore then configStore:stop(); configStore = nil end
  if wifiWatcher then wifiWatcher:stop(); wifiWatcher = nil end
end

M.start()
return M
