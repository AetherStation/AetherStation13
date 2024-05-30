import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const MainframeLinker = (props) => {
  const { act, data } = useBackend();
  const {
    peripherals = [],
  } = data;
  return (
    <Window
      width={320}
      height={400}
      title="peripheral linking tool">
      <Window.Content>
        <Section
          title="Peripherals">
          <LabeledList>
            {peripherals.map(peripheral => (
              <LabeledList.Item
                key={peripheral.index}
                label={peripheral.address.toString(16).toUpperCase()}
                buttons={
                  <>
                    <Button
                      icon="times"
                      color="bad"
                      onClick={() => act('disconnect', {
                        index: peripheral.index,
                      })} />
                    <Button
                      icon="arrow-down"
                      color="good"
                      onClick={() => act('shift_up', {
                        index: peripheral.index,
                      })} />
                    <Button icon="arrow-up"
                      color="good"
                      onClick={() => act('shift_down', {
                        index: peripheral.index,
                      })} />
                  </>
                }>
                {peripheral.name}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
