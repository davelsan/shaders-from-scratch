import { Mesh, PlaneGeometry, type Texture } from 'three';

import { ThreeState } from '@helpers/atoms';
import {
  shaderMaterial,
  type ShaderMaterialType,
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

  private shader = fragmentShader;

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
    this.texture = await assets.textures.get('plants');
  };

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = async () => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: this.shader,
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
    shaderAtom.sub(this.updateShader, { namespace: this.namespace });
  };

  private updateShader = (shader: string) => {
    this.shader = shader;
    this.setupMaterial();
    this.setupMesh();
  };
}
