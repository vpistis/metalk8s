import React, { useEffect } from 'react';
import { connect } from 'react-redux';
import { Formik, Form } from 'formik';
import styled from 'styled-components';
import { Input, Button } from '@scality/core-ui';
import {
  fetchStorageClassAction,
  createVolumeAction
} from '../ducks/app/volumes';
import { fontSize, padding } from '@scality/core-ui/dist/style/theme';

const FormSection = styled.div`
  padding: 0 ${padding.larger};
  display: flex;
  flex-direction: column;
`;

const ActionContainer = styled.div`
  display: flex;
  margin: ${padding.large} 0;
  justify-content: flex-end;
`;

const PageHeader = styled.h2`
  margin-top: 0;
`;

const CreateVolumeLayout = styled.div`
  height: 100%;
  overflow: auto;
  padding: ${padding.larger};
  display: inline-block;
  form {
    .sc-input {
      margin: ${padding.smaller} 0;
      .sc-input-label {
        width: 200px;
      }
    }
  }
`;

const SelectLabel = styled.label`
  width: 200px;
  padding: 10px;
  font-size: ${fontSize.base};
`;

const SelectField = styled.div`
  display: inline-flex;
  align-items: center;
`;

const SelectFieldItem = styled.select`
  flex-grow: 1;
`;

const CreateVolume = props => {
  let nodeName = props.match.params.id;

  useEffect(() => {
    props.fetchStorageClass();
  }, []);

  const storageClassesName = props.storageClass.map(
    storageClass => storageClass.metadata.name
  );

  // Hardcoded
  const types = [
    { label: 'RawBlockDevice', value: 'rawBlockDevice' },
    { label: 'SparseLoopDevice', value: 'sparseLoopDevice' }
  ];

  const initialValues = {
    name: '',
    storageClass: storageClassesName[0],
    type: types[0].value,
    size: '',
    path: ''
  };

  const isFormReady = storageClassesName.length > 0 && types.length > 0;

  return isFormReady ? (
    <CreateVolumeLayout>
      <PageHeader>Create a New Volume</PageHeader>
      <Formik
        initialValues={initialValues}
        onSubmit={values => {
          props.createVolume(values, nodeName);
        }}
      >
        {props => {
          const { values, handleChange } = props;
          return (
            <Form>
              <FormSection>
                <Input
                  name="name"
                  value={values.name}
                  onChange={handleChange}
                  label="Name"
                />
                <SelectField>
                  <SelectLabel>Storage Class</SelectLabel>
                  <SelectFieldItem
                    name="storageClass"
                    onChange={handleChange}
                    value={values.storageClass}
                  >
                    {storageClassesName.map((SCName, idx) => (
                      <option key={`storageClass_${idx}`} value={SCName}>
                        {SCName}
                      </option>
                    ))}
                  </SelectFieldItem>
                </SelectField>
                <SelectField>
                  <SelectLabel>Type</SelectLabel>
                  <SelectFieldItem name="type" onChange={handleChange}>
                    {types.map((type, idx) => (
                      <option key={`type_${idx}`} value={type.value}>
                        {type.label}
                      </option>
                    ))}
                  </SelectFieldItem>
                </SelectField>

                {values.type === 'sparseLoopDevice' ? (
                  <Input
                    name="size"
                    value={values.size}
                    onChange={handleChange}
                    label="Size"
                  />
                ) : (
                  <Input
                    name="path"
                    value={values.path}
                    onChange={handleChange}
                    label="Path"
                  />
                )}
              </FormSection>
              <ActionContainer>
                <Button text="Create" type="submit" />
              </ActionContainer>
            </Form>
          );
        }}
      </Formik>
    </CreateVolumeLayout>
  ) : null;
};

const mapStateToProps = state => ({
  storageClass: state.app.volumes.storageClass
});

const mapDispatchToProps = dispatch => {
  return {
    fetchStorageClass: () => dispatch(fetchStorageClassAction()),
    createVolume: (body, nodeName) =>
      dispatch(createVolumeAction(body, nodeName))
  };
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(CreateVolume);
