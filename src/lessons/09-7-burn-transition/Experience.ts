import gsap from 'gsap';
import { Mesh, PlaneGeometry, Texture, Vector2 } from 'three';

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
  uResolution: Vector2;
  uTextureDog: Texture;
  uTexturePlants: Texture;
  uTime: number;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private geometry: PlaneGeometry;
  private material: ShaderMaterial;
  private mesh: Mesh;

  private dog: Texture;
  private plants: Texture;

  constructor(state: ThreeState) {
    super('Experience', state);

    void this.init(
      this.setupAssets,
      this.setupScene,
      this.setupGeometry,
      this.setupMaterial,
      this.setupMesh,
      this.setupSubscriptions
    );

    void this.dispose(() => {
      this.material.dispose();
    });
  }

  private setupAssets = async () => {
    this.dog = await assets.textures.get('dog');
    this.plants = await assets.textures.get('plants');
  };

  private setupScene = ({ viewport }: ThreeState) => {
    viewport.maxPixelRatio = 1;
  };

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = ({ viewport }: ThreeState) => {
    console.log(this.plants);
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uResolution: new Vector2(viewport.width, viewport.height),
        uTextureDog: this.dog,
        uTexturePlants: this.plants,
        uTime: 0,
      },
    });
  };

  private setupMesh = ({ scene }: ThreeState) => {
    this.mesh = new Mesh(this.geometry, this.material);
    scene.add(this.mesh);
  };

  private setupSubscriptions = ({ viewport }: ThreeState) => {
    gsap.ticker.add((time) => {
      this.material.uTime = time;
    });

    viewport.sub(({ width, height }) => {
      this.material.uResolution.set(width, height);
    });
  };
}
