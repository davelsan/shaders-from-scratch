import { Mesh, PlaneGeometry, Vector2 } from 'three';

import { ThreeState } from '@helpers/atoms';
import {
  shaderMaterial,
  type ShaderMaterialType,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
type Uniforms = {
  uResolution: Vector2;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private geometry: PlaneGeometry;
  private mesh: Mesh;

  constructor(state: ThreeState) {
    super('Experience', state);

    void this.init(this.setupGeometry, this.setupMaterial, this.setupMesh);

    void this.dispose(() => {
      this.material.dispose();
      this.geometry.dispose();
      this.remove(this.mesh);
    });
  }

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = () => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uResolution: new Vector2(),
      },
    });
  };

  private setupMesh = () => {
    this.mesh = new Mesh(this.geometry, this.material);
    this.add(this.mesh);
  };
}
