import gsap from 'gsap';
import { Mesh, PlaneGeometry, Texture } from 'three';

import { ThreeState } from '@helpers/atoms';
import {
  shaderMaterial,
  type ShaderMaterialType,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import { assets } from './State';

type Uniforms = {
  uDiffuse: Texture;
  uTime: number;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private geometry: PlaneGeometry;
  private mesh: Mesh;
  private texture: Texture;

  constructor(state: ThreeState) {
    super('Experience', state);

    void this.init(
      this.setupAssets,
      this.setupGeometry,
      this.setupMaterial,
      this.setupMesh,
      this.setupSubscriptions
    );

    void this.dispose(() => {
      this.material.dispose();
      this.geometry.dispose();
      this.remove(this.mesh);
    });
  }

  private setupAssets = async () => {
    this.texture = await assets.textures.get('dog');
  };

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = async () => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uDiffuse: this.texture,
        uTime: 0,
      },
    });
  };

  private setupMesh = () => {
    this.mesh = new Mesh(this.geometry, this.material);
    this.add(this.mesh);
  };

  private setupSubscriptions = () => {
    gsap.ticker.add((time) => {
      this.material.uniforms.uTime.value = time;
    });
  };
}
