struct VSOut {
  @builtin(position) position: vec4<f32>,
  @location(0) life: f32,
};

@vertex
fn vs_main(
  @location(0) x: f32,
  @location(1) y: f32,
  @location(2) vx: f32,
  @location(3) vy: f32,
  @location(4) life: f32
) -> VSOut {
  var out: VSOut;

 if (life <= 0.0) {
  out.position = vec4<f32>(2.0, 2.0, 0.0, 1.0);
  out.life = 0.0;
  return out;
}

out.position = vec4<f32>(x, y, 0.0, 1.0);
out.life = life;

  return out;
}

@fragment
fn fs_main(in: VSOut) -> @location(0) vec4<f32> {
  let alpha = in.life * 0.35;     
  let gray = 0.65 + in.life * 0.25;

  return vec4<f32>(gray, gray, gray, alpha);
}