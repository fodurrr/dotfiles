local ok, hover_border = pcall(require, "hover_border")
if not ok then
  hs.alert.show("Failed to load hover_border.lua")
  return
end

hover_border.start({
  poll_interval = 0.08,
  color = { hex = "#f9e2af", alpha = 1.0 },
  width = 6,
  corner_radius = 10,
  inset = 2,
  prompt_for_accessibility = true,
})
