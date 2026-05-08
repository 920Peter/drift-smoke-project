struct Particle {
  x: f32,
  y: f32,
  vx: f32,
  vy: f32,
  life: f32,
  seed: f32,
  pad1: f32,
  pad2: f32,
};

struct Uniforms {
  time: f32,
  emitterX: f32,
  emitterY: f32,
  driftStrength: f32,
  smokeDirX: f32,
  smokeDirY: f32,
  sideDirX: f32,
  sideDirY: f32,
};

@group(0) @binding(0)
var<storage, read_write> particles: array<Particle>;

@group(0) @binding(1)
var<uniform> uniforms: Uniforms;

fn rand(n: f32) -> f32 {
  return fract(sin(n) * 43758.5453);
}

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) id: vec3<u32>) {
  let i = id.x;

  if (i >= arrayLength(&particles)) {
    return;
  }

  var p = particles[i];

  // decrease lifetime (slower fade = more smoke)
  p.life = p.life - 0.003;

  if (p.life <= 0.0) {
    // random values
    let r1 = rand(p.seed + uniforms.time);
    let r2 = rand(p.seed * 2.17 + uniforms.time);

    // respawn at emitter (rear of car)
    p.x = uniforms.emitterX + (r1 - 0.5) * 0.01;
    p.y = uniforms.emitterY + (r2 - 0.5) * 0.01;

    // velocity = backward direction + sideways spread
    p.vx = uniforms.smokeDirX * (0.002 + r1 * 0.004)
         + uniforms.sideDirX * (r2 - 0.5) * 0.012;

    p.vy = uniforms.smokeDirY * (0.002 + r1 * 0.004)
         + uniforms.sideDirY * (r2 - 0.5) * 0.012;

    // reset life
    if (rand(p.seed + uniforms.time) < uniforms.driftStrength) {
  p.life = 1.0;
} else {
  p.life = 0.0;
}

    // update seed
    p.seed = p.seed + 1.37;

  } else {
    // move particle
    p.x = p.x + p.vx * uniforms.driftStrength;
    p.y = p.y + p.vy * uniforms.driftStrength;

    // slight slowdown (air resistance)
    p.vx = p.vx * 0.985;
    p.vy = p.vy * 0.985;
  }

  particles[i] = p;
}