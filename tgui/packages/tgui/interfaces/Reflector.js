import { useBackend } from '../backend';
import { Box, Button, Flex, Stack, Icon, LabeledControls, Section, NumberInput } from '../components';
import { Window } from '../layouts';

export const Reflector = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Reflector"
      width={220}
      height={175}>
      <Window.Content>
        <Flex direction="row">
          <Flex.Item>
            <Section
              title="Presets"
              textAlign="center">
              <Stack direction="row"
                align="center">
                <Stack direction="column" fill>
                  <Stack.Item>
                    <Button
                      icon="arrow-left"
                      iconRotation={45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 315,
                      })} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="arrow-left"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 270,
                      })} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="arrow-left"
                      iconRotation={-45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 225,
                      })} />
                  </Stack.Item>
                </Stack>
                <Stack direction="column" fill>
                  <Stack.Item>
                    <Button
                      icon="arrow-up"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 0,
                      })} />
                  </Stack.Item>
                  <Stack.Item>
                    <Icon
                      name="angle-double-up"
                      size={2}
                      rotation={data.rotation_angle}
                      mb={1}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="arrow-down"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 180,
                      })} />
                  </Stack.Item>
                </Stack>
                <Stack direction="column" fill>
                  <Stack.Item>
                    <Button
                      icon="arrow-right"
                      iconRotation={-45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 45,
                      })} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="arrow-right"
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 90,
                      })} />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="arrow-right"
                      iconRotation={45}
                      mb={1}
                      onClick={() => act('rotate', {
                        rotation_angle: 135,
                      })} />
                  </Stack.Item>
                </Stack>
              </Stack>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section
              title="Angle"
              textAlign="center"
              fill>
              <LabeledControls>
                <LabeledControls.Item label="Angle regulator">
                  <Box
                    position="relative">
                    <NumberInput
                      value={data.rotation_angle}
                      unit="degrees"
                      minValue={0}
                      maxValue={359}
                      step={1}
                      stepPixelSize={2}
                      onDrag={(e, value) => act('rotate', {
                        rotation_angle: value,
                      })} />
                  </Box>
                </LabeledControls.Item>
              </LabeledControls>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
