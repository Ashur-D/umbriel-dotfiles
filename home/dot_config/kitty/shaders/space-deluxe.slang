#language slang 2026

import kitty_custom_shader_types;

static const int LAYERS = 3;
static const float DENSITY = 15.5f;
static const float STAR_SIZE = 0.062f;
static const float BRIGHTNESS = 0.78f;
static const float BLEND_THRESH = 0.5f;
static const float FLY_SPEED = 0.04f;

float hash21(float2 p) {
    p = frac(p * float2(127.1f, 311.7f));
    p += dot(p, p + 19.19f);
    return frac(p.x * p.y);
}

float noise2D(float2 p) {
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0f - 2.0f * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0f, 0.0f));
    float c = hash21(i + float2(0.0f, 1.0f));
    float d = hash21(i + float2(1.0f, 1.0f));
    return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

float fbm(float2 p) {
    float v = 0.0f;
    float amp = 0.5f;
    [ForceUnroll]
    for (int i = 0; i < 3; i++) {
        v += amp * noise2D(p);
        p = p * 2.05f;
        amp *= 0.5f;
    }
    return v;
}

float3 getStarColor(float seedVal) {
    float h = hash21(float2(seedVal, seedVal * 1.618f));
    // Full stellar spectral classification + rare exotic hues
    if (h < 0.12f) {
        return float3(1.00f, 0.45f, 0.38f); // M-type: Crimson / coral red giant
    } else if (h < 0.28f) {
        return float3(1.00f, 0.70f, 0.36f); // K-type: Rich amber / orange
    } else if (h < 0.46f) {
        return float3(1.00f, 0.92f, 0.64f); // G-type: Solar gold / champagne
    } else if (h < 0.68f) {
        return float3(0.96f, 0.98f, 1.00f); // A-type: Diamond white
    } else if (h < 0.84f) {
        return float3(0.65f, 0.90f, 1.00f); // B-type: Icy cyan-blue
    } else if (h < 0.93f) {
        return float3(0.45f, 0.68f, 1.00f); // O-type: Deep sapphire supergiant
    } else {
        return float3(0.88f, 0.60f, 1.00f); // Exotic Wolf-Rayet: Amethyst violet
    }
}

float spikeRay(float across, float along, float thickness, float lengthLimit) {
    float l = max(0.0f, 1.0f - abs(along) / lengthLimit);
    float w = exp(-abs(across) / max(thickness, 1e-4f));
    return l * l * w;
}

float getMeteors(float2 uv, float t) {
    float period = 5.0f;
    float cycleID = floor(t / period);
    float cycleTime = fmod(t, period);

    float duration = 0.65f;
    if (cycleTime > duration) return 0.0f;

    float progress = cycleTime / duration;

    float startX = 0.25f + hash21(float2(cycleID, 17.1f)) * 0.65f;
    float startY = 0.65f + hash21(float2(cycleID, 43.3f)) * 0.30f;
    float2 origin = float2(startX, startY);

    float2 dir = normalize(float2(-1.4f, -0.75f));
    float travelDist = 0.55f;

    float2 head = origin + dir * (progress * travelDist);
    float tailLen = 0.20f * (1.0f - progress * 0.35f);
    float2 tail = head - dir * tailLen;

    float2 pa = uv - head;
    float2 ba = tail - head;
    float ba2 = dot(ba, ba);
    float h = clamp(dot(pa, ba) / max(ba2, 1e-6f), 0.0f, 1.0f);
    float dist = length(pa - ba * h);

    float headGlow = 1.0f - smoothstep(0.0f, 0.007f, length(uv - head));
    float body = (1.0f - smoothstep(0.0005f, 0.004f, dist)) * (1.0f - h);
    float life = (1.0f - smoothstep(0.65f, 1.0f, progress)) * smoothstep(0.0f, 0.08f, progress);

    return max(headGlow * 1.6f, body) * life * 2.2f;
}

float3 starCell(float2 cellID, float2 cellUV, float layer, float t) {
    float2 seed = cellID + float2(layer * 17.3f, layer * 5.7f);
    float2 pos = float2(0.26f + hash21(seed) * 0.48f, 0.26f + hash21(seed + 0.5f) * 0.48f);

    float2 delta = cellUV - pos;
    float dist = length(delta);

    float starRand = hash21(seed + 2.0f);
    float typeRand = hash21(seed + 9.1f);
    float size = STAR_SIZE * (0.34f + pow(starRand, 1.4f) * 0.76f);

    float twinkleSpeed = 0.3f + hash21(seed + 5.0f) * 0.8f;
    float twinklePhase = hash21(seed + 6.0f) * 6.28318f;
    float twinkle = 0.72f + 0.28f * sin(t * twinkleSpeed + twinklePhase);

    float alpha = (0.45f + hash21(seed + 3.0f) * 0.55f) * BRIGHTNESS * twinkle;
    float3 baseCol = getStarColor(seed.x + seed.y * 31.0f);

    // Leave ~22% of grid cells empty for a more spacious, natural sky
    if (hash21(seed + 11.3f) < 0.22f) return float3(0.0f);

    // 1. Crisp Pinpoints & Classic Stars (62%)
    if (typeRand < 0.62f) {
        float pinSize = size * 0.65f;
        float core = 1.0f - smoothstep(pinSize * 0.08f, pinSize * 0.42f, dist);
        float glow = exp(-dist / (pinSize * 0.35f)) * 0.35f;
        float intensity = (core + glow) * alpha;
        return lerp(baseCol, float3(1.0f), core * 0.6f) * intensity;
    }

    // 2. Corona Halo Supergiants (10%)
    if (typeRand < 0.72f) {
        float core = 1.0f - smoothstep(size * 0.08f, size * 0.38f, dist);
        float corona = exp(-dist / (size * 0.85f)) * 0.65f * smoothstep(size * 2.8f, size * 0.2f, dist);
        float3 col = float3(1.0f) * (core * 1.2f) + baseCol * corona;
        return col * alpha;
    }

    // 3. Orbiting Binary Star System (7%)
    if (typeRand < 0.79f) {
        float orbitAngle = t * 0.45f + twinklePhase;
        float2 orbitDir = float2(cos(orbitAngle), sin(orbitAngle));
        float sep = size * 0.75f;

        float d1 = length(delta - orbitDir * sep * 0.55f);
        float d2 = length(delta + orbitDir * sep * 0.85f);

        float s1 = (1.0f - smoothstep(size * 0.06f, size * 0.32f, d1)) + exp(-d1 / (size * 0.30f)) * 0.35f;
        float s2 = (1.0f - smoothstep(size * 0.05f, size * 0.24f, d2)) + exp(-d2 / (size * 0.22f)) * 0.30f;

        float3 col1 = float3(1.00f, 0.84f, 0.52f);
        float3 col2 = float3(0.58f, 0.88f, 1.00f);
        return (col1 * s1 + col2 * s2 * 0.85f) * alpha;
    }

    // 4. 8-Point Hubble Cross + Diagonal X-Spikes + Airy Ring (6%)
    if (typeRand < 0.85f) {
        float core = 1.0f - smoothstep(size * 0.08f, size * 0.40f, dist);
        float flareLen = size * 3.6f;
        float thick = size * 0.09f;

        float plusSpikes = spikeRay(delta.y, delta.x, thick, flareLen)
                         + spikeRay(delta.x, delta.y, thick, flareLen);

        float2 rot45 = float2(delta.x + delta.y, delta.y - delta.x) * 0.70710678f;
        float xSpikes = (spikeRay(rot45.y, rot45.x, thick * 0.8f, flareLen * 0.6f)
                      +  spikeRay(rot45.x, rot45.y, thick * 0.8f, flareLen * 0.6f)) * 0.55f;

        float airyRing = exp(-abs(dist - size * 1.15f) / (size * 0.12f)) * 0.28f;

        float3 col = float3(1.0f) * core + baseCol * (plusSpikes + xSpikes + airyRing);
        return col * alpha * 1.15f;
    }

    // 5. 6-Point James Webb (JWST) Hexagonal Spikes (5%)
    if (typeRand < 0.90f) {
        float core = 1.0f - smoothstep(size * 0.08f, size * 0.40f, dist);
        float flareLen = size * 3.5f;
        float thick = size * 0.085f;

        float2 p60  = float2( delta.x * 0.5f + delta.y * 0.8660254f, -delta.x * 0.8660254f + delta.y * 0.5f);
        float2 p120 = float2(-delta.x * 0.5f + delta.y * 0.8660254f, -delta.x * 0.8660254f - delta.y * 0.5f);

        float hexSpikes = spikeRay(delta.y, delta.x, thick, flareLen)
                        + spikeRay(p60.y,   p60.x,   thick, flareLen)
                        + spikeRay(p120.y,  p120.x,  thick, flareLen);

        float halo = exp(-dist / (size * 0.65f)) * 0.35f;
        float3 col = float3(1.0f) * core + baseCol * (hexSpikes * 0.9f + halo);
        return col * alpha * 1.15f;
    }

    // 6. Distant Tilted Spiral Micro-Galaxy (4%)
    if (typeRand < 0.94f) {
        float galAngle = hash21(seed + 4.1f) * 6.28318f;
        float ca = cos(galAngle), sa = sin(galAngle);
        float2 gP = float2(delta.x * ca - delta.y * sa, delta.x * sa + delta.y * ca);

        float tilt = 0.38f + hash21(seed + 7.3f) * 0.45f;
        float2 galUV = float2(gP.x, gP.y / tilt);
        float r = length(galUV);
        float theta = atan2(galUV.y, galUV.x);

        float galSize = size * 1.45f;
        float spinDir = (starRand > 0.5f) ? 1.0f : -1.0f;
        float armPhase = theta * 2.0f - (r / max(galSize * 0.38f, 1e-4f)) * spinDir * 2.2f + t * 0.25f * spinDir;
        float arms = pow(0.5f + 0.5f * cos(armPhase), 2.2f);

        float diskEnv = exp(-r / (galSize * 0.75f)) * smoothstep(galSize * 2.2f, galSize * 0.2f, r);
        float bulge = exp(-r / (galSize * 0.22f)) * 1.35f;

        float3 coreCol = float3(1.00f, 0.88f, 0.62f);
        float3 armCol = (hash21(seed + 8.4f) > 0.4f)
            ? float3(0.55f, 0.82f, 1.00f)
            : float3(0.90f, 0.65f, 1.00f);

        return (coreCol * bulge + armCol * (arms * diskEnv * 0.95f)) * alpha * 1.15f;
    }

    // 7. Pleiades Open Star Cluster (3%)
    if (typeRand < 0.97f) {
        float haze = exp(-dist / (size * 1.15f)) * smoothstep(size * 2.8f, size * 0.2f, dist) * 0.38f;
        float3 clusterCol = float3(0.25f, 0.65f, 1.00f) * haze;

        [ForceUnroll]
        for (int k = 0; k < 6; k++) {
            float fk = float(k);
            float2 kSeed = seed + float2(fk * 13.7f, fk * 29.3f);
            float angle = hash21(kSeed) * 6.28318f;
            float rad = (0.15f + hash21(kSeed + 1.0f) * 0.85f) * size * 1.4f;
            float2 subDelta = delta - float2(cos(angle), sin(angle)) * rad;
            float subDist = length(subDelta);

            float subSize = size * (0.28f + (k < 2 ? 0.25f : 0.08f));
            float subTwinkle = 0.7f + 0.3f * sin(t * (0.8f + fk * 0.3f) + fk * 1.9f);
            float subCore = 1.0f - smoothstep(subSize * 0.08f, subSize * 0.42f, subDist);

            float subSpikes = 0.0f;
            if (k < 2) {
                subSpikes = (spikeRay(subDelta.y, subDelta.x, subSize * 0.14f, subSize * 2.8f)
                           + spikeRay(subDelta.x, subDelta.y, subSize * 0.14f, subSize * 2.8f)) * 0.7f;
            }

            float3 sisterCol = (k == 4) ? float3(1.00f, 0.88f, 0.62f) : float3(0.72f, 0.92f, 1.00f);
            clusterCol += (float3(1.0f) * subCore + sisterCol * subSpikes) * subTwinkle * 0.85f;
        }

        return clusterCol * alpha;
    }

    // 8. Planetary Ring Nebula — M57 / Helix (3%)
    float rot = hash21(seed + 4.3f) * 6.28318f;
    float cr = cos(rot), sr = sin(rot);
    float2 rP = float2(delta.x * cr - delta.y * sr, delta.x * sr + delta.y * cr);
    float tilt = 0.65f + hash21(seed + 7.1f) * 0.35f;
    float r = length(float2(rP.x, rP.y / tilt));

    float ringRadius = size * 1.15f;
    float whiteDwarf = 1.0f - smoothstep(size * 0.04f, size * 0.20f, dist);
    float innerCavity = exp(-r / (ringRadius * 0.72f)) * 0.55f;
    float outerShell = exp(-abs(r - ringRadius) / (size * 0.24f)) * 1.05f;

    float3 innerCol = float3(0.18f, 0.92f, 0.88f) * innerCavity;
    float3 shellCol = lerp(float3(1.00f, 0.40f, 0.68f), float3(1.00f, 0.78f, 0.38f), hash21(seed + 8.9f)) * outerShell;

    return (float3(1.0f) * whiteDwarf + innerCol + shellCol) * alpha;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float2 uv = t.pos;
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float aspect = pixelDims.x / max(pixelDims.y, 1.0f);

    // Interactive mouse gravitational lens
    float2 mousePos = d.mouse_pos.xy;
    if (mousePos.x >= 0.0f && mousePos.x <= 1.0f && mousePos.y >= 0.0f && mousePos.y <= 1.0f) {
        float2 toMouse = uv - mousePos;
        float2 toMouseAspect = toMouse * float2(aspect, 1.0f);
        float distToMouse = length(toMouseAspect);

        float lensFalloff = smoothstep(0.40f, 0.02f, distToMouse);
        float warpStrength = 0.022f / (distToMouse * 4.0f + 0.08f);
        uv += (toMouse / (distToMouse + 1e-4f)) * warpStrength * lensFalloff;
    }

    float2 centeredUV = (uv - 0.5f) * float2(aspect, 1.0f);
    float t_time = fmod(d.timestamp, 86400.0f);

    // Galactic camera roll and organic drift
    float angle = sin(t_time * 0.04f) * 0.08f + t_time * 0.006f;
    float cosA = cos(angle);
    float sinA = sin(angle);
    centeredUV = float2(centeredUV.x * cosA - centeredUV.y * sinA, centeredUV.x * sinA + centeredUV.y * cosA);
    centeredUV += float2(sin(t_time * 0.035f) * 0.07f, cos(t_time * 0.025f) * 0.04f);

    float2 screenDist = abs(uv - 0.5f) * 2.0f;
    float edgeDist = max(screenDist.x, screenDist.y);
    float edgeFade = 1.0f - smoothstep(0.92f, 1.02f, edgeDist);

    // Subtle drifting nebula dust
    float2 nebCoord = centeredUV * 1.4f + float2(t_time * 0.010f, t_time * 0.007f);
    float n1 = fbm(nebCoord);
    float n2 = fbm(nebCoord + float2(5.2f, 1.3f) - float2(t_time * 0.005f, 0.0f));
    float nebVal = smoothstep(0.38f, 0.78f, (n1 + n2) * 0.5f) * 0.14f;
    float3 nebCol = lerp(float3(0.35f, 0.12f, 0.45f), float3(0.08f, 0.30f, 0.45f), n2) * nebVal * edgeFade;

    float3 starLight = float3(0.0f);

    [ForceUnroll]
    for (int i = 0; i < LAYERS; i++) {
        float fi = float(i);

        float depth = 0.4f + fi * 0.5f;
        float progress = fmod(t_time * FLY_SPEED * depth, 1.0f);
        float zoom = 1.0f + progress;

        float cycleFade = smoothstep(0.0f, 0.12f, progress) * (1.0f - smoothstep(0.88f, 1.0f, progress));

        float2 zoomedUV = centeredUV / zoom;
        float scale = DENSITY * (1.0f + fi * 0.4f);
        float2 gridUV = zoomedUV * scale;
        float2 cellID = floor(gridUV);
        float2 cellUV = frac(gridUV);

        float3 cellCol = starCell(cellID, cellUV, fi, t_time);
        starLight += cellCol * ((1.0f - fi * 0.2f) * edgeFade * cycleFade);
    }

    // Shooting star contribution
    float meteor = getMeteors(uv, t_time) * edgeFade;
    float3 meteorCol = float3(1.0f, 0.96f, 0.88f) * meteor;

    float luma = dot(color.rgb, float3(0.299f, 0.587f, 0.114f));
    float blend = smoothstep(BLEND_THRESH * 0.4f, BLEND_THRESH, 1.0f - luma);
    float3 col = color.rgb + (starLight + nebCol + meteorCol) * blend;

    return float4(col, color.a);
}
