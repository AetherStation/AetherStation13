import { useBackend } from '../backend';
import { Section, Button, NoticeBox, Box, Flex, LabeledList, NumberInput } from '../components';
import { Window } from '../layouts';

export const MainframeLibrary = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    inserted,
    roms,
  } = data;
  return (
    <Window
      width={280}
      height={450}
      title="ROM database">
      <Window.Content>
        <Section
          title="Database"
          scrollable
          fill
          buttons={
            <Button
              content="Save"
              disabled={!inserted}
              color="good"
              onClick={() => act('save')} />
          }>
          <LabeledList>
            {roms.map(name => (
              <LabeledList.Item
                key={name}
                label={name}
                buttons={
                  <>
                    <Button
                      color="good"
                      content="Load"
                      disabled={!inserted}
                      onClick={() => act('load', { name: name })} />
                    <Button
                      color="bad"
                      content="Delete"
                      onClick={() => act('delete', { name: name })} />
                  </>
                } />
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
