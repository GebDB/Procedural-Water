#version 330 core

in vec3 FragPos;
in vec3 Normal;
in vec3 ViewDir; 
out vec4 FragColor;

uniform vec3 lightPos;
uniform vec3 lightDirIn;
uniform vec3 lightColor;
uniform vec3 viewPos;

uniform float shininess;
uniform float fresnelBias;
uniform float fresnelStrength;
uniform float fresnelShininess;

uniform vec3 ambient;
uniform vec3 diffuseReflectance;
uniform vec3 specularReflectance;
uniform vec3 fresnelColor;

uniform float fogDensity;   
uniform samplerCube skybox; 

void main()
{
    vec3 normal = normalize(Normal);
    vec3 lightDir = normalize(lightDirIn);
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 halfwayDir = normalize(lightDir + viewDir);

    // Ambient component
    vec3 ambientComp = ambient * lightColor;

    // Diffuse component
    float ndotl = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = lightColor * diffuseReflectance * ndotl;

    // Specular component
    float ndoth = max(dot(normal, halfwayDir), 0.0);
    vec3 specular = lightColor * specularReflectance * pow(ndoth, shininess) * ndotl;

    // Fresnel effect
    float fresnelFactor = fresnelBias + fresnelStrength * pow(1.0 - dot(viewDir, normal), fresnelShininess);
    vec3 fresnel = fresnelColor * fresnelFactor;

    // Reflection from skybox
    vec3 reflectionVector = reflect(-viewDir, normal);
    vec3 skyboxReflection = texture(skybox, reflectionVector).rgb;

    // Fog effect
    float fogFactor = exp(-fogDensity * FragPos.y);
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    // Combine all components
    vec3 lightingColor = ambientComp + diffuse + specular + fresnel;
    //vec3 lightingColor = ambientComp + diffuse + specular;
    vec3 finalColor = mix(lightingColor, skyboxReflection, .5 * fresnelFactor); 
    finalColor = mix(finalColor, vec3(0.0), 1.0 - fogFactor);            

    FragColor = vec4(finalColor, 1.0);
}
