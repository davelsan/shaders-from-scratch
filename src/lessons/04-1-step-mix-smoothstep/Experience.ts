import { Mesh, PlaneGeometry, type Texture } from 'three';

import {
  shaderMaterial,
  type ShaderMaterialType,
  type State,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import { assets, shaderAtom } from './State';

type Uniforms = {
  uDiffuse: Texture;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private geometry: PlaneGeometry;
  private mesh: Mesh;
  private texture: Texture;

  constructor(state: State) {
    super('Vector Operations', state);

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
    const plantsAtom = assets.texturesFamily('plants');
    const plants = await this._state.store.get(plantsAtom);
    this.texture = plants;
  };

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = async (shader = fragmentShader) => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: shader,
      uniforms: {
        uDiffuse: this.texture,
      },
    });
  };

  private setupMesh = () => {
    this.mesh = new Mesh(this.geometry, this.material);
    this.add(this.mesh);
  };

  private setupSubscriptions = () => {
    this.subToAtom(shaderAtom, this.updateShader);
  };

  private updateShader = (shader: string) => {
    this.setupMaterial(shader);
    this.setupMesh();
  };
}
