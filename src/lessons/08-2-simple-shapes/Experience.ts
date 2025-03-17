import gsap from 'gsap';
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
  uTime: number;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private geometry: PlaneGeometry;
  private material: ShaderMaterial;
  private mesh: Mesh;

  constructor(state: ThreeState) {
    super('Vector Operations', state);

    void this.init(
      this.setupGeometry,
      this.setupMaterial,
      this.setupMesh,
      this.setupSubscriptions
    );

    void this.dispose(() => {
      this.material.dispose();
    });
  }

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = ({ viewport }: ThreeState) => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uResolution: new Vector2(viewport.width, viewport.height),
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
      this.material.uniforms.uResolution.value.set(width, height);
    });
  };
}
