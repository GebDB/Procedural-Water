#version 330 core

// FBM implementation
#define NUM_OCTAVES 12

float mod289(float x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 perm(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

float noise(vec3 p) {
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float fbm(vec3 x) {
    float v = 0.0;
    float a = 0.5;
    vec3 shift = vec3(100.0);
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(x);
        x = x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Vertex attributes
layout(location = 0) in vec3 aPos;

// Outputs to fragment shader
out vec3 FragPos; 
out vec3 Normal;  
out vec2 TexCoords; 

// Uniforms
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float time;          

uniform float amplitude;     
uniform float frequency;     
const float PI = 3.141592;

void main() {
    // Compute FBM-based displacement
    vec3 worldPosition = aPos;
    vec3 fbmInput = vec3(aPos.x * frequency, aPos.z * frequency, time * 0.25);
    float fbmValue = fbm(fbmInput);

    // Apply displacement
    vec3 totalDisplacement = vec3(0.0, amplitude * fbmValue, 0.0);
    vec3 animatedPos = worldPosition + totalDisplacement;

    // Compute world-space position
    FragPos = vec3(model * vec4(animatedPos, 1.0));

    // Calculate normals using finite differences
    float delta = 0.1; 
    float fbmValueX = fbm(fbmInput + vec3(delta, 0.0, 0.0));
    float fbmValueZ = fbm(fbmInput + vec3(0.0, 0.0, delta));

    vec3 tangentX = vec3(1.0, amplitude * (fbmValueX - fbmValue) / delta, 0.0);
    vec3 tangentZ = vec3(0.0, amplitude * (fbmValueZ - fbmValue) / delta, 1.0);

    vec3 normal = normalize(cross(tangentZ, tangentX));
    Normal = normalize(mat3(transpose(inverse(model))) * normal);

    TexCoords = aPos.xz; 
    gl_Position = projection * view * vec4(FragPos, 1.0);
}



//------------------------------------------------------//





/** 
//Gerstner wave implementation
layout(location = 0) in vec3 aPos; // Vertex position

out vec3 FragPos; // World-space position
out vec3 Normal;  // Computed normal

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float time;

// Parameters for multiple Gerstner waves
const int NUM_WAVES = 4;
uniform vec2 waveDirections[NUM_WAVES]; 
uniform float amplitudes[NUM_WAVES];    
uniform float speeds[NUM_WAVES];       
uniform float wavelengths[NUM_WAVES];   
uniform float steepnesses[NUM_WAVES];  

void main()
{
    vec3 totalDisplacement = vec3(0.0);
    vec3 totalNormal = vec3(0.0, 1.0, 0.0); // Start with the up vector

    for (int i = 0; i < NUM_WAVES; ++i)
    {
        vec2 normDir = normalize(waveDirections[i]);

        // Compute wave number (k = 2pi / wavelength)
        float waveNumber = 2.0 * 3.14159265359 / wavelengths[i];

        // Compute angular frequency (w = speed * waveNumber)
        float omega = speeds[i] * waveNumber;

        // Calculate phase (theta = k * (d · x) - w * t)
        float phase = waveNumber * dot(vec2(aPos.x, aPos.z), normDir) - omega * time;

        // Calculate wave displacement
        float cosPhase = cos(phase);
        float sinPhase = sin(phase);
        float amplitude = amplitudes[i];
        float steepness = steepnesses[i];

        vec3 displacement = vec3(
            normDir.x * (steepness * amplitude) * cosPhase,
            amplitude * sinPhase,
            normDir.y * (steepness * amplitude) * cosPhase
        );

        totalDisplacement += displacement;

        // Calculate wave normal
        vec3 waveNormal = vec3(
            -normDir.x * waveNumber * amplitude * cosPhase,
            1.0 - steepness * waveNumber * amplitude * sinPhase,
            -normDir.y * waveNumber * amplitude * cosPhase
        );

        totalNormal += waveNormal;
    }

    vec3 animatedPos = aPos + totalDisplacement;

    FragPos = vec3(model * vec4(animatedPos, 1.0));

    Normal = normalize(mat3(transpose(inverse(model))) * totalNormal);

    gl_Position = projection * view * vec4(FragPos, 1.0);
}
**/