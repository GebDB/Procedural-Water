#version 330 core

layout (location = 0) in vec3 aPos; 
layout (location = 1) in vec3 aNormal; 
layout (location = 2) in vec2 aTexCoords; 

out VS_OUT {
    vec3 FragPos;
    vec3 Normal;
    vec2 TexCoords;
} fs_in;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    fs_in.FragPos = vec3(model * vec4(aPos, 1.0)); 
    fs_in.Normal = mat3(transpose(inverse(model))) * aNormal; 
    fs_in.TexCoords = aTexCoords;

    gl_Position = projection * view * vec4(fs_in.FragPos, 1.0);
}
