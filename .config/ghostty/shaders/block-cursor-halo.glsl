// Smooth block cursor with a short green phosphor trail.
const float MOVE_DURATION = 0.12;
const float TRAIL_DURATION = 0.24;
const vec3 HALO_COLOR = vec3(0.32, 1.0, 0.48);

float blockDistance(vec2 pixel, vec4 cursor) {
    vec2 center = vec2(cursor.x + cursor.z * 0.5, cursor.y - cursor.w * 0.5);
    vec2 delta = abs(pixel - center) - cursor.zw * 0.5;
    return length(max(delta, vec2(0.0))) + min(max(delta.x, delta.y), 0.0);
}

float blockMask(vec2 pixel, vec4 cursor) {
    return 1.0 - smoothstep(-0.5, 0.5, blockDistance(pixel, cursor));
}

float blockHalo(vec2 pixel, vec4 cursor, float radius) {
    float outside = max(0.0, blockDistance(pixel, cursor));
    return exp(-outside * outside / (2.0 * radius * radius));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);
    if (iFocus == 0 || iCursorVisible == 0 || iCurrentCursorStyle != 0 ||
        iCurrentCursor.z <= 0.0 || iCurrentCursor.w <= 0.0) return;

    float radius = max(1.5, iCurrentCursor.w * 0.12);
    float age = max(iTime - iTimeCursorChange, 0.0);
    vec2 movement = iCurrentCursor.xy - iPreviousCursor.xy;
    bool shortMove = abs(movement.y) <= iCurrentCursor.w * 1.25 &&
                     length(movement) > 0.5 &&
                     length(movement) <= iCurrentCursor.w * 8.0;
    vec4 head = iCurrentCursor;
    float glow = 0.0;

    if (shortMove && age < TRAIL_DURATION) {
        float progress = clamp(age / MOVE_DURATION, 0.0, 1.0);
        float eased = 1.0 - pow(1.0 - progress, 4.0);
        head.xy = mix(iPreviousCursor.xy, iCurrentCursor.xy, eased);

        if (age < MOVE_DURATION) {
            // Clear the native block while the animated block approaches it.
            float nativeMask = blockMask(fragCoord, iCurrentCursor);
            fragColor.rgb = mix(fragColor.rgb, iBackgroundColor * fragColor.a, nativeMask);
            float headMask = blockMask(fragCoord, head);
            fragColor = mix(fragColor, iCurrentCursorColor, headMask * 0.9);
        }

        float fade = pow(1.0 - age / TRAIL_DURATION, 1.5);
        // Soft additive light leaves underlying letters readable.
        for (int i = 0; i < 10; i++) {
            float along = float(i) / 9.0;
            vec4 tail = head;
            tail.xy = mix(iPreviousCursor.xy, head.xy, along);
            glow += blockHalo(fragCoord, tail, radius * 1.5)
                    * (0.025 + 0.055 * along) * fade;
        }
    }

    // A small halo also surrounds the resting block cursor.
    glow += blockHalo(fragCoord, head, radius) * 0.16;
    fragColor.rgb += HALO_COLOR * glow * (vec3(1.0) - fragColor.rgb);
    fragColor.rgb = clamp(fragColor.rgb, 0.0, 1.0);
}
