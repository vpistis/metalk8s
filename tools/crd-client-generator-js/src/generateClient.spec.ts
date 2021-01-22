import { generateClient } from "./generateClient";

const path = require('path');
const fs = require('fs');

describe('client generator', () => {
    it('should generate expected cluster scoped client given v1beta1 clustered scoped CRD file', () => {
        const crdFile = path.join(__dirname, './__TESTS__/v1beta1.clustered.crd.yaml');
        const destFile = path.join(__dirname, './__TESTS__/expected.js');
        const expectedFile = path.join(__dirname, './__TESTS__/expected.v1beta1.clustered.crd.client.js');

        const result = generateClient(crdFile, destFile, 'Metalk8s');
        expect(result).toBe(fs.readFileSync(expectedFile, {encoding:'utf8'}));
    })

    it('should generate expected namespaced scoped client given v1beta1 namespaced scoped CRD file', () => {
      const crdFile = path.join(__dirname, './__TESTS__/v1beta1.namespaced.crd.yaml');
      const destFile = path.join(__dirname, './__TESTS__/expected.js');
      const expectedFile = path.join(__dirname, './__TESTS__/expected.v1beta1.namespaced.crd.client.js');

      const result = generateClient(crdFile, destFile);
      expect(result).toBe(fs.readFileSync(expectedFile, {encoding:'utf8'}));
  })

})
