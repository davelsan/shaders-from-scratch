import { Experience } from './Experience';
import { state } from './State';

export const createExperience = () => new Experience(state);
