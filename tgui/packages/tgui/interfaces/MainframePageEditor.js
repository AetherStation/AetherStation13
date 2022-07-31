import { useBackend, useLocalState } from '../backend';
import { Box, Button, NoticeBox } from '../components';
import { Window } from '../layouts';

export const MainframePageEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    memory,
  } = data;
  const [
    editedMemory,
    setEditedMemory,
  ] = useLocalState(context, 'editedMemory', memory);
  const [
    currentNibble,
    setCurrentNibble,
  ] = useLocalState(context, 'currentNibble', 0);

  const listmemory = () => {
    const elements = [];
    for (let y = 0; y < 16; y++) {
      for (let x = 0; x < 16; x++) {
        let ind = (x + y * 16) * 2;
        elements.push(
          <>
            <Box
              as="span"
              mr="1px"
              backgroundColor={ind === currentNibble ? "green" : "blue"}
              onClick={() => {
                setCurrentNibble(ind);
              }}>
              {editedMemory[ind]}
            </Box>
            <Box
              as="span"
              mr="2px"
              backgroundColor={ind + 1 === currentNibble ? "green" : "blue"}
              onClick={() => {
                setCurrentNibble(ind + 1);
              }}>
              {editedMemory[ind + 1]}
            </Box>
          </>
        );
      }
      elements.push(<Box mt="2px" />);
    }
    return elements;
  };

  const replace_at = (string, index, r) => {
    return string.substring(0, index) + r + string.substring(index + 1);
  };
  const hex_regex = new RegExp('[0-9A-F]');

  return (
    <Window
      title="ROM Bank Editor"
      width={360}
      height={400}>
      <Window.Content
        onKeyDown={e => {
          e.preventDefault();
          const key = String.fromCharCode(
            window.event ? e.which : e.keyCode);
          if (!hex_regex.test(key)) { return; }
          setEditedMemory(
            replace_at(editedMemory, currentNibble, key));
          setCurrentNibble(currentNibble + 1);
          return;
        }}>
        {!data.inserted && (
          <NoticeBox danger>
            No ROM bank inserted.
          </NoticeBox>
        ) || (
          <>
            <Box
              fontFamily="monospace">
              {listmemory()}
            </Box>
            <Button color="good" content="Save"
              onClick={() => act('save', {
                data: editedMemory,
              })} />
          </>
        )}
      </Window.Content>
    </Window>
  );
};
