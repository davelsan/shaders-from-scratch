import { Mesh, NearestFilter, PlaneGeometry, Texture, Vector2 } from 'three';

import { ThreeState } from '@helpers/atoms';
import {
  shaderMaterial,
  type ShaderMaterialType,
  WebGLView,
} from '@helpers/three';

import fragmentShader from './shader.frag.glsl';
import vertexShader from './shader.vert.glsl';
import {
  assets,
  FilterType,
  filterType,
  TargetType,
  targetType,
} from './State';

type Uniforms = {
  uResolution: Vector2;
  uTexture: Texture;
  uTextureSize: Vector2;
  // Debug
  uFilterType: FilterType;
  uTargetType: TargetType;
};

type ShaderMaterial = ShaderMaterialType<typeof ShaderMaterial>;
const ShaderMaterial = shaderMaterial<Uniforms>();

export class Experience extends WebGLView {
  private geometry: PlaneGeometry;
  private material: ShaderMaterial;
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
    });
  }

  private setupAssets = async () => {
    this.texture = await assets.textures.get('colors');
    this.texture.minFilter = NearestFilter;
    this.texture.magFilter = NearestFilter;
  };

  private setupGeometry = () => {
    this.geometry = new PlaneGeometry(2, 2, 1, 1);
  };

  private setupMaterial = ({ viewport }: ThreeState) => {
    this.material = new ShaderMaterial({
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      uniforms: {
        uFilterType: filterType.get(),
        uTargetType: targetType.get(),
        uResolution: new Vector2(viewport.width, viewport.height),
        uTexture: this.texture,
        uTextureSize: new Vector2(2.0, 2.0),
      },
    });
  };

  private setupMesh = ({ scene }: ThreeState) => {
    this.mesh = new Mesh(this.geometry, this.material);
    scene.add(this.mesh);
  };

  private setupSubscriptions = ({ viewport }: ThreeState) => {
    viewport.sub(({ width, height }) => {
      this.material.uniforms.uResolution.value.set(width, height);
    });

    filterType.sub((value) => {
      this.material.uFilterType = value;
    });

    targetType.sub((value) => {
      this.material.uTargetType = value;
    });
  };
}
