#language slang 2026

import kitty_custom_shader_types;

static const int LAYERS = 3;
static const float DENSITY = 20.0f;
static const float STAR_SIZE = 0.06f;
static const float BRIGHTNESS = 0.7f;
static const float BLEND_THRESH = 0.5f;
static const float FLY_SPEED = 0.04f;

float hash21(float2 p) {
    p = frac(p * float2(127.1f, 311.7f));
    p += dot(p, p + 19.19f);
    return frac(p.x * p.y);
}

float getMeteors(float2 uv, float t) {
    float period = 4.5f; // Meteor cycle
    float cycleID = floor(t / period);
    float cycleTime = fmod(t, period);

    float duration = 0.65f;
    if (cycleTime > duration) return 0.0f;

    float progress = cycleTime / duration;

    // Randomize trajectory per cycle
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

    return max(headGlow * 1.6f, body) * life * 2.5f;
}

float starCell(float2 cellID, float2 cellUV, float layer, float t) {
    float2 seed = cellID + float2(layer * 17.3f, layer * 5.7f);
    float2 pos = float2(0.2f + hash21(seed) * 0.6f, 0.2f + hash21(seed + 0.5f) * 0.6f);

    float dist = length(cellUV - pos);
    float size = STAR_SIZE * (0.4f + hash21(seed + 2.0f) * 0.6f);

    float twinkleSpeed = 0.3f + hash21(seed + 5.0f) * 0.5f;
    float twinklePhase = hash21(seed + 6.0f) * 6.28318f;
    float twinkle = 0.75f + 0.25f * sin(t * twinkleSpeed + twinklePhase);

    float alpha = (0.5f + hash21(seed + 3.0f) * 0.5f) * BRIGHTNESS * twinkle;

    return alpha * (1.0f - smoothstep(size * 0.1f, size * 0.5f, dist));
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float2 uv = t.pos;
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float aspect = pixelDims.x / max(pixelDims.y, 1.0f);

    float2 centeredUV = (uv - 0.5f) * float2(aspect, 1.0f);
    float t_time = fmod(d.timestamp, 86400.0f);
    float brightness = 0.0f;

    float2 screenDist = abs(uv - 0.5f) * 2.0f;
    float edgeDist = max(screenDist.x, screenDist.y);
    float edgeFade = 1.0f - smoothstep(0.92f, 1.02f, edgeDist);

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

        brightness += starCell(cellID, cellUV, fi, t_time) * (1.0f - fi * 0.2f) * edgeFade * cycleFade;
    }

    // Shooting star contribution
    float meteor = getMeteors(uv, t_time) * edgeFade;

    float luma = dot(color.rgb, float3(0.299f, 0.587f, 0.114f));
    float blend = smoothstep(BLEND_THRESH * 0.4f, BLEND_THRESH, 1.0f - luma);
    float3 starCol = float3(0.9f, 0.93f, 1.0f) * brightness;
    float3 meteorCol = float3(1.0f, 0.96f, 0.88f) * meteor;
    float3 col = color.rgb + (starCol + meteorCol) * blend;

    return float4(col, color.a);
}
