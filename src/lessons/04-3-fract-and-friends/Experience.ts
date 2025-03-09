import { Mesh, PlaneGeometry, Vector2 } from 'three';

import { ThreeState } from '@helpers/atoms';
import { ViewportAtomValue } from '@helpers/atoms/atomWithViewport';
import {
  shaderMaterial,
  type ShaderMaterialType,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import { fnBinding, modFnValueBinding } from './State';

type Uniforms = {
  uFunction: number;
  uModFnValue: number;
  uResolution: Vector2;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private material: ShaderMaterial;
  private geometry: PlaneGeometry;
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
      this.geometry.dispose();
      this.remove(this.mesh);
    });
  }

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = async ({ viewport }: ThreeState) => {
    const { height, width } = viewport;
    const fn = fnBinding.get();

    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uFunction: fn,
        uModFnValue: 1.0,
        uResolution: new Vector2(width, height),
      },
    });
  };

  private setupMesh = () => {
    this.mesh = new Mesh(this.geometry, this.material);
    this.add(this.mesh);
  };

  private setupSubscriptions = ({ viewport }: ThreeState) => {
    fnBinding.sub(this.updateFunction);
    modFnValueBinding.sub(this.updateModFnValue);
    viewport.sub(this.updateResolution);
  };

  private updateFunction = (value: number) => {
    this.material.uniforms.uFunction.value = value;
  };

  private updateModFnValue = (value: number) => {
    this.material.uniforms.uModFnValue.value = value;
  };

  private updateResolution = ({ height, width }: ViewportAtomValue) => {
    this.material.uniforms.uResolution.value.set(width, height);
  };
}
