#language slang 2026

import kitty_custom_shader_types;

static const int LAYERS = 3;
static const float DENSITY = 20.0f;
static const float STAR_SIZE = 0.06f;
static const float BRIGHTNESS = 0.6f;
static const float3 STAR_COLOR = float3(0.9f, 0.93f, 1.0f);
static const float BLEND_THRESH = 0.5f;
static const float FLY_SPEED = 0.04f;

float hash(float2 p) {
    p = frac(p * float2(127.1f, 311.7f));
    p += dot(p, p + 19.19f);
    return frac(p.x * p.y);
}

float starCell(float2 cellID, float2 cellUV, float layer, float t) {
    float2 seed = cellID + float2(layer * 17.3f, layer * 5.7f);
    float2 pos = float2(0.2f + hash(seed) * 0.6f, 0.2f + hash(seed + 0.5f) * 0.6f);

    float dist = length(cellUV - pos);
    float size = STAR_SIZE * (0.4f + hash(seed + 2.0f) * 0.6f);

    float twinkleSpeed = 0.3f + hash(seed + 5.0f) * 0.5f;
    float twinklePhase = hash(seed + 6.0f) * 6.28318f;
    float twinkle = 0.75f + 0.25f * sin(t * twinkleSpeed + twinklePhase);

    float alpha = (0.5f + hash(seed + 3.0f) * 0.5f) * BRIGHTNESS * twinkle;

    return alpha * (1.0f - smoothstep(size * 0.1f, size * 0.5f, dist));
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float2 uv = t.pos;
    float2 pixelDims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float aspect = pixelDims.x / max(pixelDims.y, 1.0f);

    // center the UV so origin is middle of screen
    float2 centeredUV = (uv - 0.5f) * float2(aspect, 1.0f);

    float t_time = d.timestamp;
    float brightness = 0.0f;

    [ForceUnroll]
    for (int i = 0; i < LAYERS; i++) {
        float fi = float(i);

        // each layer zooms at a different depth — parallax
        float depth = 0.4f + fi * 0.5f;
        float zoom = 1.0f + fmod(t_time * FLY_SPEED * depth, 1.0f);

        // expand UV outward from center over time
        float2 zoomedUV = centeredUV / zoom;

        float scale = DENSITY * (1.0f + fi * 0.4f);
        float2 gridUV = zoomedUV * scale;
        float2 cellID = floor(gridUV);
        float2 cellUV = frac(gridUV);

        // fade out stars only right at the screen edges (full-extent fade)
        float2 screenDist = abs(uv - 0.5f) * 2.0f;
        float edgeDist = max(screenDist.x, screenDist.y);
        float edgeFade = 1.0f - smoothstep(0.92f, 1.02f, edgeDist);

        brightness += starCell(cellID, cellUV, fi, t_time) * (1.0f - fi * 0.2f) * edgeFade;
    }

    float luma = dot(color.rgb, float3(0.299f, 0.587f, 0.114f));
    float blend = smoothstep(BLEND_THRESH * 0.4f, BLEND_THRESH, 1.0f - luma);
    float3 col = color.rgb + STAR_COLOR * brightness * blend;

    return float4(col, color.a);
}
