// Bright monochrome phosphor for the orange SSH and green local profiles.
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);
    bool orangeProfile = iForegroundColor.r > iForegroundColor.g * 1.25 &&
                         iForegroundColor.g > iForegroundColor.b * 1.25;
    bool greenProfile = iForegroundColor.g > iForegroundColor.r * 1.25 &&
                        iForegroundColor.g > iForegroundColor.b * 1.25;
    if (!orangeProfile && !greenProfile) return;

    // Peak intensity keeps blue/purple app text readable after recolouring.
    float intensity = max(fragColor.r, max(fragColor.g, fragColor.b));
    float backgroundPeak = max(iBackgroundColor.r, max(iBackgroundColor.g, iBackgroundColor.b));
    // Leave the dark background and CRT edge shading unamplified.
    if (intensity <= backgroundPeak + 0.002) return;
    intensity = clamp((intensity - backgroundPeak) / max(1.0 - backgroundPeak, 0.001), 0.0, 1.0);
    float foregroundPeak = max(iForegroundColor.r, max(iForegroundColor.g, iForegroundColor.b));
    vec3 phosphor = iForegroundColor / max(foregroundPeak, 0.001);
    // Lift dim text and glow while leaving pure black unchanged.
    intensity = min(1.0, pow(clamp(intensity, 0.0, 1.0), 0.60) * 1.15);
    fragColor.rgb = iBackgroundColor + (vec3(1.0) - iBackgroundColor) * phosphor * intensity;
}
