-- hover_border disabled — had issues, kept commented for reference.
-- local ok, hover_border = pcall(require, "hover_border")
-- if not ok then
--   hs.alert.show("Failed to load hover_border.lua")
--   return
-- end
--
-- hover_border.start({
--   poll_interval = 0.08,
--   color = { hex = "#f9e2af", alpha = 1.0 },
--   width = 6,
--   corner_radius = 10,
--   inset = 2,
--   prompt_for_accessibility = true,
-- })

local ok_wifi, _ = pcall(require, "wifi_ethernet_toggle")
if not ok_wifi then
  hs.alert.show("Failed to load wifi_ethernet_toggle.lua")
end
